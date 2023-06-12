open! Core
open Tic_tac_toe_2023_common
open Protocol
open Bonsai_web

let player_to_string player =
  match player with
  | Player.Server_bot difficulty -> [%string "%{difficulty#Difficulty} bot"]
  | Player.Player player -> Username.to_string player
;;

let piece_to_string ~piece ~game_state =
  Game_state.get_player game_state ~piece |> player_to_string
;;

let render_game_status (game_state : Game_state.t) =
  match game_state.game_status with
  | Turn_of piece -> View.textf "%s's turn" (piece_to_string ~piece ~game_state)
  | Game_over { winner = None } -> View.text "tie"
  | Game_over { winner = Some (piece, _winning_pieces) } ->
    View.textf "Winner: %s" (piece_to_string ~piece ~game_state)
;;

let render_game_kind theme game_kind =
  Chip.render_chip
    ~theme
    ~intent:
      (match game_kind with
       | Game_kind.Omok -> View.Intent.Info
       | Tic_tac_toe -> View.Intent.Success)
    (Game_kind.to_string_hum game_kind)
;;
