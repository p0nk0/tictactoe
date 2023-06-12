open! Core
open! Bonsai_web
open Tic_tac_toe_2023_common
open Protocol

let me_var =
  Persistent_var.create
    (module struct
      type t = Username.t Or_waiting.t [@@deriving sexp]
    end)
    `Local_storage
    ~unique_id:"js-tictactoe-me"
    ~default:Or_waiting.Waiting
;;

let random_image_var =
  Bonsai.Dynamic_scope.create ~name:"jsip-random-image" ~fallback:Images.Capybara ()
;;

let random_image = Bonsai.Dynamic_scope.lookup random_image_var
let set_me me = Effect.of_sync_fun (Persistent_var.set me_var) (Or_waiting.Resolved me)
let me = Bonsai.read (Persistent_var.value me_var)

let me_once =
  let open Bonsai.Let_syntax in
  let%sub { last_ok_response; _ } =
    Rpc_effect.Rpc.poll_until_ok
      ~equal_query:[%equal: unit]
      ~where_to_connect:Self
      ~retry_interval:(Time_ns.Span.of_sec 0.5)
      Me.rpc
      (Value.return ())
  in
  match%sub last_ok_response with
  | None -> Bonsai.const Or_waiting.Waiting
  | Some (_, response) ->
    let%arr response = response in
    Or_waiting.Resolved response
;;

let joinable_games =
  let open Bonsai.Let_syntax in
  let%sub { last_ok_response; _ } =
    Rpc_effect.Rpc.poll
      ~equal_query:[%equal: unit]
      ~where_to_connect:Self
      ~every:(Time_ns.Span.of_sec 1.0)
      List_all_joinable_games.rpc
      (Value.return ())
  in
  match%sub last_ok_response with
  | None -> Bonsai.const Or_waiting.Waiting
  | Some (_, response) ->
    let%arr response = response in
    Or_waiting.Resolved response
;;

let games_with_two_players =
  let open Bonsai.Let_syntax in
  let%sub { last_ok_response; _ } =
    Rpc_effect.Rpc.poll
      ~equal_query:[%equal: unit]
      ~where_to_connect:Self
      ~every:(Time_ns.Span.of_sec 1.0)
      Show_all_games_with_two_players.rpc
      (Value.return ())
  in
  match%sub last_ok_response with
  | None -> Bonsai.const Or_waiting.Waiting
  | Some (_, response) ->
    let%arr response = response in
    Or_waiting.Resolved response
;;

let get_game ~game_id =
  let open Bonsai.Let_syntax in
  let%sub { last_ok_response; _ } =
    Rpc_effect.Rpc.poll
      ~where_to_connect:Self
      ~equal_query:[%equal: Game_id.t]
      ~every:(Time_ns.Span.of_sec 0.2)
      Get_game.rpc
      game_id
  in
  match%sub last_ok_response with
  | None -> Bonsai.const Or_waiting.Waiting
  | Some (_query, response) ->
    let%arr response = response in
    Or_waiting.Resolved response
;;

let take_turn =
  let open Bonsai.Let_syntax in
  let%sub me = me in
  match%sub me with
  | Or_waiting.Waiting -> Bonsai.const Or_waiting.Waiting
  | Or_waiting.Resolved me ->
    let%sub send_rpc = Rpc_effect.Rpc.dispatcher ~where_to_connect:Self Take_turn.rpc in
    let%arr send_rpc = send_rpc
    and me = me in
    Or_waiting.Resolved
      (fun ~game_id position ->
         let%bind.Effect response =
           send_rpc { username = me; txt = { game_id; position } }
         in
         match response with
         | Ok Ok -> Effect.Ignore
         | Ok
             (( Game_does_not_exist
              | Not_your_turn
              | Game_is_over
              | Position_out_of_bounds
              | Position_already_occupied
              | You_are_not_a_player_in_this_game ) as error) ->
           Effect.print_s
             [%message
               "There was an error while taking a turn!" (error : Take_turn.Response.t)]
         | Error error ->
           Effect.print_s
             [%message
               "There was a connection error while taking a turn!" (error : Error.t)])
;;

let is_thinking ~game_id =
  let open Bonsai.Let_syntax in
  let%sub { last_ok_response; _ } =
    Rpc_effect.Rpc.poll
      ~where_to_connect:Self
      ~equal_query:[%equal: Game_id.t]
      ~every:(Time_ns.Span.of_sec 1.0)
      Is_thinking.rpc
      game_id
  in
  let%arr last_ok_response = last_ok_response in
  Option.value_map ~default:false last_ok_response ~f:Tuple2.get2
;;

let start_services ~random_image computation =
  let open Bonsai.Let_syntax in
  let%sub () =
    let%sub me = me in
    match%sub me with
    | Or_waiting.Resolved _ -> Bonsai.const ()
    | Waiting ->
      let%sub me_once = me_once in
      (match%sub me_once with
       | Waiting -> Bonsai.const ()
       | Resolved me ->
         let%sub on_activate =
           let%arr me = me in
           set_me me
         in
         Bonsai.Edge.lifecycle ~on_activate ())
  in
  Bonsai.Dynamic_scope.set
    random_image_var
    (Value.return random_image)
    ~inside:computation
;;
