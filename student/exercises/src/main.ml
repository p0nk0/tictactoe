open Core
open Tic_tac_toe_2023_common
open Protocol

module Evaluation = struct
  type t =
    | Illegal_state
    | Win of Piece.t
    | Game_continues
  [@@deriving sexp_of]

  let to_string (t : t) = t |> sexp_of_t |> Sexp.to_string
end

module Possible_moves = struct
  type t = Position.t list option [@@deriving sexp_of]
end

(* Here are some functions which know how to create a couple different kinds of games *)
let empty_game =
  let game_id = Game_id.of_int 0 in
  let game_kind = Game_kind.Tic_tac_toe in
  let player_x = Player.Player (Username.of_string "Player_X") in
  let player_o = Player.Player (Username.of_string "Player_O") in
  let game_status = Game_status.Turn_of Piece.X in
  { Game_state.game_id
  ; game_kind
  ; player_x
  ; player_o
  ; pieces = Position.Map.empty
  ; game_status
  }
;;

let place_piece (game : Game_state.t) ~piece ~position : Game_state.t =
  let pieces = Map.set game.pieces ~key:position ~data:piece in
  { game with pieces }
;;

let win_for_x =
  empty_game
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 0; column = 0 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 1; column = 0 }
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 2; column = 2 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 2; column = 0 }
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 2; column = 1 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 1; column = 1 }
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 0; column = 2 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 0; column = 1 }
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 1; column = 2 }
;;

let non_win =
  empty_game
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 0; column = 0 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 1; column = 0 }
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 2; column = 2 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 2; column = 0 }
;;

let evaluate (game : Game_state.t) : Evaluation.t =
  ignore game;
  failwith "Implement me!"
;;

let available_moves (game : Game_state.t) : Possible_moves.t =
  ignore game;
  failwith "Implement me!"
;;

let winning_moves (game : Game_state.t) piece : Possible_moves.t =
  ignore game;
  ignore piece;
  failwith "Implement me!"
;;

let losing_moves (game : Game_state.t) piece : Possible_moves.t =
  ignore game;
  ignore piece;
  failwith "Implement me!"
;;

let exercise_one =
  Command.basic
    ~summary:"Exercise 1: Did is the game over?"
    (let%map_open.Command () = return () in
     fun () ->
       let evaluation = evaluate win_for_x in
       print_s [%sexp (evaluation : Evaluation.t)])
;;

let exercise_two =
  Command.basic
    ~summary:"Exercise 2: Where can I move?"
    (let%map_open.Command () = return () in
     fun () ->
       let moves = available_moves win_for_x in
       print_s [%sexp (moves : Possible_moves.t)];
       let moves = available_moves non_win in
       print_s [%sexp (moves : Possible_moves.t)])
;;

let exercise_three =
  let piece_options =
    Piece.all |> List.map ~f:Piece.to_string |> String.concat ~sep:", "
  in
  Command.basic
    ~summary:"Exercise 3: Is there a winning move?"
    (let%map_open.Command () = return ()
     and piece =
       flag
         "piece"
         (required (Arg_type.create Piece.of_string))
         ~doc:("PIECE " ^ piece_options)
     in
     fun () ->
       let winning_moves = winning_moves non_win piece in
       print_s [%sexp (winning_moves : Possible_moves.t)];
       ())
;;

let exercise_four =
  let piece_options =
    Piece.all |> List.map ~f:Piece.to_string |> String.concat ~sep:", "
  in
  Command.basic
    ~summary:"Exercise 4: Is there a losing move?"
    (let%map_open.Command () = return ()
     and piece =
       flag
         "piece"
         (required (Arg_type.create Piece.of_string))
         ~doc:("PIECE " ^ piece_options)
     in
     fun () ->
       let losing_moves = losing_moves non_win piece in
       print_s [%sexp (losing_moves : Possible_moves.t)];
       ())
;;

let%expect_test "print_win_for_x" =
  print_endline (Game_state.to_string_hum win_for_x);
  [%expect
    {|
    ((game_id 0)(game_kind Tic_tac_toe)(player_x(Player Player_X))(player_o(Player Player_O))(game_status(Turn_of X)))
    XOX
    OOX
    OXX |}]
;;

let%expect_test "print_non_win" =
  print_endline (Game_state.to_string_hum non_win);
  [%expect
    {|
    ((game_id 0)(game_kind Tic_tac_toe)(player_x(Player Player_X))(player_o(Player Player_O))(game_status(Turn_of X)))
    X
    O
    O X |}]
;;

(* When you've implemented the [evaluate] function, uncomment the next two tests! *)
(* let%expect_test "evalulate_win_for_x" =
 *   print_endline (win_for_x |> evaluate |> Evaluation.to_string);
 *   [%expect {| (Win X) |}]
 * ;;
 *
 * let%expect_test "evalulate_non_win" =
 *   print_endline (non_win |> evaluate |> Evaluation.to_string);
 *   [%expect {| Game_continues |}]
 * ;; *)

(* After you've implemented [available_moves], uncomment these tests! *)
(* let%expect_test "yes available_moves" =
 *   let (moves : Possible_moves.t) =
 *     available_moves non_win |> Option.map ~f:(List.sort ~compare:Position.compare)
 *   in
 *   print_s [%sexp (moves : Possible_moves.t)];
 *   [%expect
 *     {|
 *     ((((row 0) (column 1)) ((row 0) (column 2)) ((row 1) (column 1))
 *       ((row 1) (column 2)) ((row 2) (column 1)))) |}]
 * ;;
 *
 * let%expect_test "no available_moves" =
 *   let (moves : Possible_moves.t) =
 *     available_moves win_for_x |> Option.map ~f:(List.sort ~compare:Position.compare)
 *   in
 *   print_s [%sexp (moves : Possible_moves.t)];
 *   [%expect {| () |}]
 * ;; *)

(* When you've implemented the [winning_moves] function, uncomment this test! *)
(* let%expect_test "winning_move" =
 *   let positions = winning_moves non_win Piece.X in
 *   print_s [%sexp (positions : Possible_moves.t)];
 *   [%expect {| ((((row 1) (column 1)))) |}];
 *   let positions = winning_moves non_win Piece.O in
 *   print_s [%sexp (positions : Possible_moves.t)];
 *   [%expect {| () |}]
 * ;; *)

(* When you've implemented the [losing_moves] function, uncomment this test! *)
(* let%expect_test "print_losing" =
 *   let positions = losing_moves non_win Piece.X in
 *   print_s [%sexp (positions : Possible_moves.t)];
 *   [%expect {| () |}];
 *   let positions = losing_moves non_win Piece.O in
 *   print_s [%sexp (positions : Possible_moves.t)];
 *   [%expect
 *     {|
 *     ((((row 0) (column 1)) ((row 0) (column 2)) ((row 1) (column 2))
 *       ((row 2) (column 1)))) |}]
 * ;; *)
