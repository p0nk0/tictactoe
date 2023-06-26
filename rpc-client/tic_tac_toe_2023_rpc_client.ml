open! Core
open Tic_tac_toe_2023_common
open Protocol
open Async

type t = { connection : Async.Rpc.Connection.t }

let create ~uri =
  let open Deferred.Or_error.Let_syntax in
  let%bind connection = Rpc_websocket.Rpc.client uri in
  return { connection }
;;

let create_binding rpc t ~query = Rpc.Rpc.dispatch rpc t.connection query
let create_game = create_binding Create_game.rpc
let join_existing_game = create_binding Join_existing_game.rpc

let show_all_games_with_two_players t =
  create_binding Show_all_games_with_two_players.rpc t ~query:()
;;

let get_game = create_binding Get_game.rpc
let list_all_joinable_games t = create_binding List_all_joinable_games.rpc t ~query:()
let take_turn = create_binding Take_turn.rpc
let me t = create_binding Me.rpc t ~query:()

type game_ai = me:Piece.t -> game_state:Game_state.t -> Position.t

let game_loop t ~refresh_rate ~me ~game_id ~(game_ai : game_ai) =
  let open Deferred.Or_error.Let_syntax in
  Deferred.Or_error.repeat_until_finished () (fun () ->
    let%bind.Deferred () = Clock.after refresh_rate in
    let%bind game_state = get_game t ~query:game_id in
    match game_state with
    | Waiting_for_someone_to_join _ ->
      print_endline "Waiting for someone to join...";
      let%bind.Deferred () = Clock.after (Time_float.Span.of_sec 1.0) in
      return (`Repeat ())
    | Game_id_does_not_exist ->
      print_s [%message "Whoops, game does not exist!" (game_id : Game_id.t)];
      return (`Finished ())
    | Both_players game_state ->
      (match game_state.game_status with
       | Game_over { winner } ->
         let winner =
           Option.map winner ~f:(fun (winning_piece, _winning_positions) ->
             Game_state.get_player game_state ~piece:winning_piece)
         in
         print_s [%message "Game is over!" (winner : Player.t option)];
         return (`Finished ())
       | Turn_of piece ->
         let is_it_my_turn =
           Player.equal (Game_state.get_player game_state ~piece) (Player me)
         in
         (match is_it_my_turn with
          | false -> return (`Repeat ())
          | true ->
            let position = game_ai ~me:piece ~game_state in
            let%bind response =
              take_turn t ~query:{ username = me; txt = { position; game_id } }
            in
            (match response with
             | Take_turn.Response.Ok ->
               print_s [%message "successfully took turn!"];
               return (`Repeat ())
             | ( Take_turn.Response.Game_does_not_exist
               | Take_turn.Response.Not_your_turn
               | Take_turn.Response.Position_out_of_bounds
               | Take_turn.Response.Position_already_occupied
               | Take_turn.Response.Game_is_over
               | Take_turn.Response.You_are_not_a_player_in_this_game ) as error ->
               let msg =
                 [%message
                   "whoops there was an error while placing a turn"
                     (error : Take_turn.Response.t)]
               in
               print_s msg;
               Deferred.return (Error (Error.of_string (Sexp.to_string msg)))))))
;;

let create_game_and_play t ~me ~against ~game_kind ~(game_ai : game_ai) ~refresh_rate =
  let open Deferred.Or_error.Let_syntax in
  let%bind game_id =
    create_game
      t
      ~query:{ username = me; txt = { game_kind; against_server_bot = against } }
  in
  print_endline [%string "successfully created game with id: '%{game_id#Game_id}'"];
  game_loop t ~me ~game_id ~game_ai ~refresh_rate
;;

let join_game_and_play t ~game_id ~me ~(game_ai : game_ai) ~refresh_rate =
  let open Deferred.Or_error.Let_syntax in
  let%bind response = join_existing_game t ~query:{ username = me; txt = game_id } in
  match response with
  | Ok | You've_already_joined_this_game ->
    print_endline "successfully joined game";
    game_loop t ~game_id ~me ~game_ai ~refresh_rate
  | (Game_already_ended | Game_already_full | Game_does_not_exist) as error ->
    Deferred.Or_error.error_s
      [%message
        "Error while attempting to join game: " (error : Join_existing_game.Response.t)]
;;

let create_game_and_play_against_self t ~me ~game_kind ~(game_ai : game_ai) ~refresh_rate =
  let open Deferred.Or_error.Let_syntax in
  let%bind game_id =
    create_game t ~query:{ username = me; txt = { game_kind; against_server_bot = None } }
  in
  let%bind response = join_existing_game t ~query:{ username = me; txt = game_id } in
  match response with
  | Ok | You've_already_joined_this_game ->
    print_endline "successfully joined game";
    game_loop t ~game_id ~me ~game_ai ~refresh_rate
  | (Game_already_ended | Game_already_full | Game_does_not_exist) as error ->
    Deferred.Or_error.error_s
      [%message
        "Error while attempting to join game: " (error : Join_existing_game.Response.t)]
;;
