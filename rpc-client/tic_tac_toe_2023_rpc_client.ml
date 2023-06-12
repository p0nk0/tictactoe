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
