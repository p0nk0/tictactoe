open Core
open Tic_tac_toe_2023_common
open Protocol

module Evaluation : sig
  type t =
    | Illegal_state
    | Game_over  of { winner : Protocol.Piece.t option } 
    | Game_continues

  val to_string : t -> string
end

val evaluate : game_kind:Protocol.Game_kind.t -> pieces:Protocol.Piece.t Protocol.Position.Map.t -> Evaluation.t
val available_moves : game_kind:Game_kind.t -> pieces:Piece.t Position.Map.t -> Position.t list
val winning_moves : Protocol.Game_state.t -> Protocol.Piece.t -> Position.t list
val losing_moves : Protocol.Game_state.t -> Protocol.Piece.t -> Position.t list
val exercise_one : Command.t
val exercise_two : Command.t
val exercise_three : Command.t
val exercise_four : Command.t
