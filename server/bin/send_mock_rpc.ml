open! Core
open Async
open Tic_tac_toe_2023_common
open Protocol
module Rpc_client = Tic_tac_toe_2023_rpc_client

let command =
  Command.async_or_error
    ~summary:
      "Send off an rpc to create and join a game and then randomly places pieces using \
       web socket rpc"
    (let%map_open.Command port =
       flag "port" (optional_with_default 8181 int) ~doc:"port on which to serve"
     and host = flag "host" (required string) ~doc:"The host to connect to" in
     fun () ->
       let open Deferred.Or_error.Let_syntax in
       let%bind client =
         let uri =
           Uri.empty
           |> Fn.flip Uri.with_host (Some host)
           |> Fn.flip Uri.with_port (Some port)
         in
         Rpc_client.create ~uri
       in
       let username = Username.of_string "bulbasaur" in
       let%bind game_id =
         Rpc_client.create_game
           client
           ~query:
             { With_username.username
             ; txt = { game_kind = Omok; against_server_bot = None }
             }
       in
       let%bind join_game_response =
         Rpc_client.join_existing_game client ~query:{ username; txt = game_id }
       in
       (match join_game_response with
        | Ok -> print_endline "successfully joined game"
        | _ -> ());
       Deferred.Or_error.repeat_until_finished () (fun () ->
         let%bind game_state = Rpc_client.get_game client ~query:game_id in
         match game_state with
         | Both_players game_state ->
           (match game_state.game_status with
            | Game_status.Game_over { winner } ->
              let winner =
                Option.map winner ~f:(fun (winning_piece, _winning_positions) ->
                  Game_state.get_player game_state ~piece:winning_piece)
              in
              print_s [%message "Game is over!" (winner : Player.t option)];
              return (`Finished ())
            | Game_status.Turn_of _ ->
              (* I am both players >.> *)
              let position =
                let all_positions =
                  let board_length = Game_kind.board_length game_state.game_kind in
                  let%bind.List row = List.init board_length ~f:Fn.id in
                  let%map.List column = List.init board_length ~f:Fn.id in
                  { Position.row; column }
                in
                let free_positions =
                  List.filter all_positions ~f:(fun position ->
                    not (Map.mem game_state.pieces position))
                in
                List.random_element free_positions
                |> Option.value_exn ~message:"Whoops, no more available spots"
              in
              let%bind.Deferred () = Clock.after (Time_float.Span.of_sec 0.1) in
              let%bind response =
                Rpc_client.take_turn
                  client
                  ~query:{ username; txt = { position; game_id = game_state.game_id } }
              in
              (match response with
               | Take_turn.Response.Ok -> print_s [%message "successfully took turn!"]
               | ( Take_turn.Response.Game_does_not_exist
                 | Take_turn.Response.Not_your_turn
                 | Take_turn.Response.Position_out_of_bounds
                 | Take_turn.Response.Position_already_occupied
                 | Take_turn.Response.Game_is_over
                 | Take_turn.Response.You_are_not_a_player_in_this_game ) as error ->
                 print_s
                   [%message
                     "whoops there was an error while placing a turn"
                       (error : Take_turn.Response.t)]);
              return (`Repeat ()))
         | Get_game.Response.Waiting_for_someone_to_join _ ->
           print_s
             [%message
               "Whoops, expected the game to have started, but found a joinable game \
                instead."];
           return (`Finished ())
         | Get_game.Response.Game_id_does_not_exist ->
           print_s [%message "Whoops, game does not exist!"];
           return (`Finished ())))
;;

let () = Command_unix.run command
