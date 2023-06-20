open Core
open Tic_tac_toe_2023_common

module Evaluation : sig
  type t =
    | Illegal_state
    | Win of Protocol.Piece.t
    | Game_continues

  val to_string : t -> string
end

module Possible_moves : sig
  type t = Protocol.Position.t list option [@@deriving sexp_of]
end

val evaluate : Protocol.Game_state.t -> Evaluation.t
val available_moves : Protocol.Game_state.t -> Possible_moves.t
val winning_moves : Protocol.Game_state.t -> Protocol.Piece.t -> Possible_moves.t
val losing_moves : Protocol.Game_state.t -> Protocol.Piece.t -> Possible_moves.t
val exercise_one : Command.t
val exercise_two : Command.t
val exercise_three : Command.t
val exercise_four : Command.t
