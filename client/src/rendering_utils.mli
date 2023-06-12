open! Core
open Tic_tac_toe_2023_common
open Protocol
open Bonsai_web

val player_to_string : Player.t -> string
val render_game_kind : View.Theme.t -> Game_kind.t -> Vdom.Node.t
val render_game_status : Game_state.t -> Vdom.Node.t
