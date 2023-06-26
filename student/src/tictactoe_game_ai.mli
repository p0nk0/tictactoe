open! Core
open Tic_tac_toe_2023_common
open Protocol

(** [compute_next_move] is your Game AI's function.

    [game_ai.exe] will connect, communicate, and play with the game server,
    and will use [compute_next_move] to pick which pieces to put on your
    behalf.

    [compute_next_move] is only called whenever it is your turn, the game
    isn't yet over, so feel free to raise in cases where there are no
    available spots to pick. *)
val compute_next_move : me:Piece.t -> game_state:Game_state.t -> Position.t
