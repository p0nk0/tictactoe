open Core
open Tic_tac_toe_2023_common
open Protocol

module Evaluation = struct
  type t =
    | Illegal_state
    | Game_over of { winner : Piece.t option }
    | Game_continues
  [@@deriving sexp_of]

  let to_string (t : t) = t |> sexp_of_t |> Sexp.to_string
end

(* Here are some functions which know how to create a couple different kinds
   of games *)
let empty_game_TTT =
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

let empty_game_omok =
  let game_id = Game_id.of_int 0 in
  let game_kind = Game_kind.Omok in
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
  empty_game_TTT
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
  empty_game_TTT
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 0; column = 0 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 1; column = 0 }
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 2; column = 2 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 2; column = 0 }
;;

let diag_win_for_o =
  empty_game_TTT
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 0; column = 0 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 1; column = 0 }
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 2; column = 2 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 2; column = 0 }
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 2; column = 1 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 1; column = 1 }
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 0; column = 1 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 0; column = 2 }
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 1; column = 2 }
;;

let invalid_state =
  empty_game_TTT
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 0; column = 0 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 2; column = 1 }
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 2; column = 2 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 2; column = 0 }
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 1; column = 0 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 1; column = 1 }
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 0; column = 2 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 0; column = 1 }
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 1; column = 2 }
;;

let non_win_omok =
  empty_game_omok
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 0; column = 0 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 3; column = 8 }
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 4; column = 2 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 13; column = 9 }
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 13; column = 8 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 13; column = 5 }
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 3; column = 5 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 5; column = 4 }
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 4; column = 12 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 10; column = 8 }
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 3; column = 3 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 9; column = 9 }
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 5; column = 8 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 3; column = 5 }
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 6; column = 7 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 4; column = 4 }
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 8; column = 12 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 18; column = 13 }
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 13; column = 14 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 15; column = 4 }
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 7; column = 1 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 11; column = 7 }
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 12; column = 3 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 8; column = 14 }
;;

let win_for_o =
  empty_game_TTT
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 0; column = 0 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 1; column = 0 }
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 2; column = 2 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 2; column = 1 }
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 1; column = 2 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 1; column = 1 }
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 2; column = 0 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 0; column = 1 }
;;

let win_for_x_omok =
  empty_game_omok
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 2; column = 1 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 0; column = 4 }
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 2; column = 2 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 1; column = 4 }
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 2; column = 3 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 1; column = 5 }
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 2; column = 4 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 2; column = 6 }
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 2; column = 5 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 3; column = 7 }
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 3; column = 2 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 3; column = 4 }
;;

let win_for_o_omok =
  empty_game_omok
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 2; column = 1 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 0; column = 4 }
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 2; column = 2 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 1; column = 4 }
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 2; column = 3 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 1; column = 5 }
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 2; column = 4 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 2; column = 6 }
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 4; column = 5 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 3; column = 7 }
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 3; column = 2 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 4; column = 8 }
;;

let minor_diag_win_for_x_omok =
  empty_game_omok
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 1; column = 0 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 5; column = 4 }
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 14; column = 0 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 2; column = 8 }
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 13; column = 1 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 12; column = 5 }
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 12; column = 2 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 5; column = 6 }
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 11; column = 3 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 5; column = 8 }
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 10; column = 4 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 4; column = 8 }
;;

let minor_diag_win_for_x_2_omok =
  empty_game_omok
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 1; column = 10 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 5; column = 4 }
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 14; column = 10 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 2; column = 8 }
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 13; column = 11 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 12; column = 5 }
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 12; column = 12 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 5; column = 6 }
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 11; column = 13 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 5; column = 8 }
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 10; column = 14 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 4; column = 8 }
;;

let invalid_omok =
  empty_game_omok
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 2; column = 1 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 0; column = 4 }
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 2; column = 2 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 1; column = 4 }
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 2; column = 3 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 1; column = 5 }
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 2; column = 4 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 2; column = 6 }
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 4; column = 5 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 3; column = 7 }
  |> place_piece ~piece:Piece.X ~position:{ Position.row = 2; column = 5 }
  |> place_piece ~piece:Piece.O ~position:{ Position.row = 4; column = 8 }
;;

let get_empty_board (game_kind : Game_kind.t) =
  let size = Game_kind.board_length game_kind in
  List.concat
    (List.init size ~f:(fun i ->
       List.init size ~f:(fun j -> { Position.row = i; Position.column = j })))
;;

(* Exercise 1.

   For instructions on implemeting this refer to the README.

   After you are done with this implementation, you can uncomment out
   "evaluate" test cases found below in this file. *)
let available_moves
  ~(game_kind : Game_kind.t)
  ~(pieces : Piece.t Position.Map.t)
  : Position.t list
  =
  Set.to_list
    (Set.diff
       (Set.of_list (module Position) (get_empty_board game_kind))
       (Set.of_list (module Position) (Map.keys pieces)))
;;

(* Exercise 2.

   For instructions on implemeting this refer to the README.

   After you are done with this implementation, you can uncomment out
   "evaluate" test cases found below in this file. *)

(* checks # of steps (length) in direction from starting point *)
let scan
  length
  (start : Position.t)
  direction
  (pieces : Piece.t Position.Map.t)
  player
  =
  let empty = List.init length ~f:(fun i -> i) in
  let f =
    match direction with
    | "row" ->
      fun i ->
        { Position.row = start.row + i; Position.column = start.column }
    | "col" ->
      fun i ->
        { Position.row = start.row; Position.column = start.column + i }
    | "major" ->
      fun i ->
        { Position.row = start.row + i; Position.column = start.column + i }
    | "minor" ->
      fun i ->
        { Position.row = start.row + i; Position.column = start.column - i }
    | _ -> failwith "invalid direction"
  in
  let g x y =
    match y with None -> false | Some y -> x && Piece.equal y player
  in
  List.fold
    (List.map (List.map empty ~f) ~f:(Map.find pieces))
    ~init:true
    ~f:g
;;

(* given start pos, runs scan multiple times*)
let omok_scan length win (start : Position.t) direction pieces player =
  let offset = if String.equal direction "minor" then 4 else 0 in
  let empty = List.init (length - win + 1) ~f:(fun i -> i + offset) in
  let f =
    match direction with
    | "row" | "major" ->
      fun i ->
        { Position.row = start.row + i; Position.column = start.column }
    | "col" | "minor" ->
      fun i ->
        { Position.row = start.row; Position.column = start.column + i }
    | _ -> failwith "invalid direction"
  in
  List.fold
    (List.map (List.map empty ~f) ~f:(fun pos ->
       scan win pos direction pieces player))
    ~init:false
    ~f:( || )
;;

let check_row_col (game_kind : Game_kind.t) pieces player dir =
  let win = Game_kind.win_length game_kind in
  let board_length = Game_kind.board_length game_kind in
  let f i =
    match dir with
    | "row" -> { Position.row = 0; Position.column = i }
    | "col" -> { Position.row = i; Position.column = 0 }
    | _ -> failwith "invalid direction"
  in
  match game_kind with
  | Tic_tac_toe ->
    List.fold
      (List.map (List.init board_length ~f) ~f:(fun pos ->
         scan win pos dir pieces player))
      ~init:false
      ~f:( || )
  | Omok ->
    List.fold
      (List.map (List.init board_length ~f) ~f:(fun pos ->
         omok_scan board_length win pos dir pieces player))
      ~init:false
      ~f:( || )
;;

let omok_diags game_kind pieces player dir =
  let win = Game_kind.win_length game_kind in
  let board_length = Game_kind.board_length game_kind in
  let f i =
    match dir with
    | "major" -> { Position.row = 0; Position.column = i }
    | "minor" -> { Position.row = i; Position.column = 0 }
    | _ -> failwith "invalid direction"
  in
  List.fold
    (List.map
       (List.init (board_length - win + 1) ~f)
       ~f:(fun pos -> omok_scan board_length win pos dir pieces player))
    ~init:false
    ~f:( || )
;;

let check_diags game_kind pieces player =
  let win = Game_kind.win_length game_kind in
  match game_kind with
  | Tic_tac_toe ->
    scan win { Position.row = 0; Position.column = 0 } "major" pieces player
    || scan
         win
         { Position.row = 0; Position.column = 2 }
         "minor"
         pieces
         player
  | Omok ->
    omok_diags game_kind pieces player "major"
    || omok_diags game_kind pieces player "minor"
;;

let check_all_dirs game_kind pieces player =
  check_row_col game_kind pieces player "row"
  || check_row_col game_kind pieces player "col"
  || check_diags game_kind pieces player
;;

let board_full game_kind pieces =
  List.is_empty (available_moves ~game_kind ~pieces)
;;

(* everything works! (omok might have a few edge case errors) *)
let evaluate ~(game_kind : Game_kind.t) ~(pieces : Piece.t Position.Map.t)
  : Evaluation.t
  =
  let eval_player player = check_all_dirs game_kind pieces player in
  let x = eval_player Piece.X in
  let o = eval_player Piece.O in
  match x, o with
  | true, true -> Illegal_state
  | true, false -> Game_over { winner = Some Piece.X }
  | false, true -> Game_over { winner = Some Piece.O }
  | _ ->
    if board_full game_kind pieces
    then Game_over { winner = None }
    else Game_continues
;;

(* Exercise 3. *)
let winning_moves
  ~(me : Piece.t)
  ~(game_kind : Game_kind.t)
  ~(pieces : Piece.t Position.Map.t)
  : Position.t list
  =
  let f pos =
    let new_pieces = Map.set pieces ~key:pos ~data:me in
    match evaluate ~game_kind ~pieces:new_pieces with
    | Game_over { winner = Some n } -> Piece.equal n me
    | Game_over { winner = None } -> false
    | Game_continues -> false
    | Illegal_state -> failwith "illegal state"
  in
  List.filter (available_moves ~game_kind ~pieces) ~f
;;

(* Exercise 4. *)
let losing_moves
  ~(me : Piece.t)
  ~(game_kind : Game_kind.t)
  ~(pieces : Piece.t Position.Map.t)
  : Position.t list
  =
  let opponent_can_win me game_kind pieces =
    not (List.is_empty (winning_moves ~me ~game_kind ~pieces))
  in
  let f pos =
    let new_pieces = Map.set pieces ~key:pos ~data:me in
    opponent_can_win (Piece.flip me) game_kind new_pieces
  in
  List.filter (available_moves ~game_kind ~pieces) ~f
;;

let exercise_one =
  Command.basic
    ~summary:"Exercise 1: Where can I move?"
    (let%map_open.Command () = return () in
     fun () ->
       let moves =
         available_moves
           ~game_kind:win_for_x.game_kind
           ~pieces:win_for_x.pieces
       in
       print_s [%sexp (moves : Position.t list)];
       let moves =
         available_moves ~game_kind:non_win.game_kind ~pieces:non_win.pieces
       in
       print_s [%sexp (moves : Position.t list)])
;;

let exercise_two =
  Command.basic
    ~summary:"Exercise 2: Did is the game over?"
    (let%map_open.Command () = return () in
     fun () ->
       let evaluation =
         evaluate ~game_kind:win_for_x.game_kind ~pieces:win_for_x.pieces
       in
       print_s [%sexp (evaluation : Evaluation.t)])
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
       let winning_moves =
         winning_moves
           ~me:piece
           ~game_kind:non_win.game_kind
           ~pieces:non_win.pieces
       in
       print_s [%sexp (winning_moves : Position.t list)];
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
       let losing_moves =
         losing_moves
           ~me:piece
           ~game_kind:non_win.game_kind
           ~pieces:non_win.pieces
       in
       print_s [%sexp (losing_moves : Position.t list)];
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

(* After you've implemented [available_moves], uncomment these tests! *)
let%expect_test "yes available_moves" =
  let (moves : Position.t list) =
    available_moves ~game_kind:non_win.game_kind ~pieces:non_win.pieces
    |> List.sort ~compare:Position.compare
  in
  print_s [%sexp (moves : Position.t list)];
  [%expect
    {| 
   (((row 0) (column 1)) ((row 0) (column 2)) ((row 1) (column 1))
    ((row 1) (column 2)) ((row 2) (column 1))) |}]
;;

let%expect_test "no available_moves" =
  let (moves : Position.t list) =
    available_moves ~game_kind:win_for_x.game_kind ~pieces:win_for_x.pieces
    |> List.sort ~compare:Position.compare
  in
  print_s [%sexp (moves : Position.t list)];
  [%expect {| () |}]
;;

(* let%expect_test "print time" = print_endline (Game_state.to_string_hum
   minor_diag_win_for_x_omok); [%expect {||}] ;; *)

(* When you've implemented the [evaluate] function, uncomment the next two
   tests! *)
let%expect_test "evalulate_win_for_x" =
  print_endline
    (evaluate ~game_kind:win_for_x.game_kind ~pieces:win_for_x.pieces
     |> Evaluation.to_string);
  [%expect {| (Game_over(winner(X))) |}]
;;

let%expect_test "evalulate_diag_win_for_o" =
  print_endline
    (evaluate
       ~game_kind:diag_win_for_o.game_kind
       ~pieces:diag_win_for_o.pieces
     |> Evaluation.to_string);
  [%expect {| (Game_over(winner(O))) |}]
;;

let%expect_test "evalulate_non_win" =
  print_endline
    (evaluate ~game_kind:non_win.game_kind ~pieces:non_win.pieces
     |> Evaluation.to_string);
  [%expect {| Game_continues |}]
;;

let%expect_test "evalulate_invalid_state" =
  print_endline
    (evaluate ~game_kind:invalid_state.game_kind ~pieces:invalid_state.pieces
     |> Evaluation.to_string);
  [%expect {| Illegal_state |}]
;;

let%expect_test "evalulate win_for_o" =
  print_endline
    (evaluate ~game_kind:win_for_o.game_kind ~pieces:win_for_o.pieces
     |> Evaluation.to_string);
  [%expect {| (Game_over(winner(O))) |}]
;;

let%expect_test "evaluate win_for_x_omok" =
  print_endline
    (evaluate
       ~game_kind:win_for_x_omok.game_kind
       ~pieces:win_for_x_omok.pieces
     |> Evaluation.to_string);
  [%expect {| (Game_over(winner(X))) |}]
;;

let%expect_test "evaluate non_win_omok" =
  print_endline
    (evaluate ~game_kind:non_win_omok.game_kind ~pieces:non_win_omok.pieces
     |> Evaluation.to_string);
  [%expect {| Game_continues |}]
;;

let%expect_test "evaluate win_for_x_omok" =
  print_endline
    (evaluate
       ~game_kind:win_for_o_omok.game_kind
       ~pieces:win_for_o_omok.pieces
     |> Evaluation.to_string);
  [%expect {| (Game_over(winner(O))) |}]
;;

let%expect_test "evaluate invalid_omok" =
  print_endline
    (evaluate ~game_kind:invalid_omok.game_kind ~pieces:invalid_omok.pieces
     |> Evaluation.to_string);
  [%expect {| Illegal_state |}]
;;

let%expect_test "evaluate minor_diag_win_for_x_omok" =
  print_endline
    (evaluate
       ~game_kind:minor_diag_win_for_x_omok.game_kind
       ~pieces:minor_diag_win_for_x_omok.pieces
     |> Evaluation.to_string);
  [%expect {| (Game_over(winner(X))) |}]
;;

let%expect_test "evaluate minor_diag_win_for_x_2_omok" =
  print_endline
    (evaluate
       ~game_kind:minor_diag_win_for_x_2_omok.game_kind
       ~pieces:minor_diag_win_for_x_2_omok.pieces
     |> Evaluation.to_string);
  [%expect {| (Game_over(winner(X))) |}]
;;

(* When you've implemented the [winning_moves] function, uncomment this
   test! *)
let%expect_test "winning_move" =
  let positions =
    winning_moves
      ~game_kind:non_win.game_kind
      ~pieces:non_win.pieces
      ~me:Piece.X
  in
  print_s [%sexp (positions : Position.t list)];
  [%expect {| (((row 1) (column 1)))
  |}];
  let positions =
    winning_moves
      ~game_kind:non_win.game_kind
      ~pieces:non_win.pieces
      ~me:Piece.O
  in
  print_s [%sexp (positions : Position.t list)];
  [%expect {| () |}]
;;

(* When you've implemented the [losing_moves] function, uncomment this
   test! *)
let%expect_test "print_losing" =
  let positions =
    losing_moves
      ~game_kind:non_win.game_kind
      ~pieces:non_win.pieces
      ~me:Piece.X
  in
  print_s [%sexp (positions : Position.t list)];
  [%expect {| () |}];
  let positions =
    losing_moves
      ~game_kind:non_win.game_kind
      ~pieces:non_win.pieces
      ~me:Piece.O
  in
  print_s [%sexp (positions : Position.t list)];
  [%expect
    {|
  (((row 0) (column 1)) ((row 0) (column 2)) ((row 1) (column 2))
   ((row 2) (column 1))) |}]
;;
