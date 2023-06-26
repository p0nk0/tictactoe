open! Core
open Tic_tac_toe_2023_common
open Protocol


(* Exercise 1.2. 

   Implement a game AI that just picks a random available position. Feel free
   to raise if there is not an available position.

   After you are done, update [compute_next_move] to use your [random_move_strategy].
 *)
let random_move_strategy ~(game_kind : Game_kind.t) ~(pieces : Piece.t Position.Map.t) : Position.t = 
  ignore game_kind;
  ignore pieces;
  failwith "Implement me!"
;;

(* [compute_next_move] is your Game AI's function.

   [game_ai.exe] will connect, communicate, and play with the game server, and
   will use [compute_next_move] to pick which pieces to put on your behalf. 

   [compute_next_move] is only called whenever it is your turn, the game isn't yet
   over, so feel free to raise in cases where there are no available spots to pick.
 *)
let _compute_next_move ~(me : Piece.t) ~(game_state : Game_state.t) : Position.t =
  ignore random_move_strategy;
  ignore me;
  ignore game_state;
  { Position.row = 0; column = 0 }
;;


let compute_next_move ~me:_ ~game_state = 
  let all_positions =
    let board_length = Game_kind.board_length game_state.Game_state.game_kind in
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

