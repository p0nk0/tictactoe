open! Core
open! Bonsai_web
open Tic_tac_toe_2023_common
open Protocol

val random_image : Images.t Computation.t
val set_me : Username.t -> unit Effect.t
val me : Username.t Or_waiting.t Computation.t
val joinable_games : Joinable_game.t Game_id.Map.t Or_waiting.t Computation.t

val games_with_two_players
  : Game_state.t Game_id.Map.t Or_waiting.t Computation.t

val get_game
  :  game_id:Game_id.t Value.t
  -> Get_game.Response.t Or_waiting.t Computation.t

val take_turn
  : (game_id:Game_id.t -> Position.t -> unit Effect.t) Or_waiting.t
    Computation.t

val is_thinking : game_id:Game_id.t Value.t -> bool Computation.t

val start_services
  :  random_image:Images.t
  -> 'a Computation.t
  -> 'a Computation.t
