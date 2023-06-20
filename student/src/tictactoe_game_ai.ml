open! Core
open Tic_tac_toe_2023_common
open Protocol

let compute_next_move ~me:_ ~(game_state : Game_state.t) : Position.t =
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
;;
