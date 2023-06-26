open! Core
open Async
open Tic_tac_toe_2023_common
open Protocol
module Rpc_client = Tic_tac_toe_2023_rpc_client

module Flags = struct
  open Command.Let_syntax.Let_syntax.Open_on_rhs

  let username =
    map
      ~f:Username.of_string
      (flag
         "username"
         (required string)
         ~doc:"STRING - your username, who to play as.")
  ;;

  let against =
    map
      ~f:(Option.map ~f:(Fn.compose Difficulty.t_of_sexp Sexp.of_string))
      (flag
         "against-bot"
         (optional string)
         ~doc:
           "Easy | Medium | Hard - Difficulty of the server to play \
            against. If unset will leave game open for someone else to \
            join.")
  ;;

  let game_kind =
    map
      ~f:(Fn.compose Game_kind.t_of_sexp Sexp.of_string)
      (flag
         "game-kind"
         (required string)
         ~doc:"Tic_tac_toe | Omok - Difficulty of ")
  ;;

  let refresh_rate =
    flag
      "refresh-rate"
      (optional_with_default
         (Time_float.Span.of_sec 0.1)
         Time_float_unix.Span.arg_type)
      ~doc:"How often to poll for new game state"
  ;;

  let game_id =
    map
      ~f:Game_id.of_int
      (flag "game-id" (required int) ~doc:"INT - Game ID to join.")
  ;;
end

let game_ai = Tictactoe_game_ai.compute_next_move

let create_client ~host ~port =
  let uri =
    Uri.empty
    |> Fn.flip Uri.with_host (Some host)
    |> Fn.flip Uri.with_port (Some port)
  in
  Rpc_client.create ~uri
;;

let cmd_create_game =
  Command.async_or_error
    ~summary:
      "Send off an rpc to create and game and then plays the game, waiting \
       for the other player to place pieces"
    (let%map_open.Command port =
       flag "port" (required int) ~doc:"port on which to serve"
     and host = flag "host" (required string) ~doc:"The host to connect to"
     and username = Flags.username
     and against = Flags.against
     and game_kind = Flags.game_kind
     and refresh_rate = Flags.refresh_rate in
     fun () ->
       let open Deferred.Or_error.Let_syntax in
       let%bind client = create_client ~host ~port in
       Rpc_client.create_game_and_play
         client
         ~me:username
         ~against
         ~game_kind
         ~game_ai
         ~refresh_rate)
;;

let cmd_join_game =
  Command.async_or_error
    ~summary:
      "Send off an rpc to join a game and then randomly places pieces using \
       web socket rpc"
    (let%map_open.Command port =
       flag
         "port"
         (optional_with_default 8181 int)
         ~doc:"port on which to serve"
     and host = flag "host" (required string) ~doc:"The host to connect to"
     and username = Flags.username
     and game_id = Flags.game_id
     and refresh_rate = Flags.refresh_rate in
     fun () ->
       let open Deferred.Or_error.Let_syntax in
       let%bind client = create_client ~host ~port in
       Rpc_client.join_game_and_play
         client
         ~me:username
         ~game_id
         ~game_ai
         ~refresh_rate)
;;

let cmd_play_against_self =
  Command.async_or_error
    ~summary:
      "Send off an rpc to create and then immediately start playing against \
       itself"
    (let%map_open.Command port =
       flag
         "port"
         (optional_with_default 8181 int)
         ~doc:"port on which to serve"
     and host = flag "host" (required string) ~doc:"The host to connect to"
     and username = Flags.username
     and game_kind = Flags.game_kind
     and refresh_rate = Flags.refresh_rate in
     fun () ->
       let open Deferred.Or_error.Let_syntax in
       let%bind client = create_client ~host ~port in
       Rpc_client.create_game_and_play_against_self
         client
         ~me:username
         ~game_kind
         ~game_ai
         ~refresh_rate)
;;

let command =
  Command.group
    ~summary:"Bot-running command"
    [ "create-game-and-play", cmd_create_game
    ; "join-game-and-play", cmd_join_game
    ; "create-game-and-play-against-self", cmd_play_against_self
    ]
;;

let () = Command_unix.run command
