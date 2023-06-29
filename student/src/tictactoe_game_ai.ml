open! Core
open Tic_tac_toe_2023_common
open Protocol

(* Exercise 1.2.

   Implement a game AI that just picks a random available position. Feel free
   to raise if there is not an available position.

   After you are done, update [compute_next_move] to use your
   [random_move_strategy]. *)
let random_move_strategy
  ~(game_kind : Game_kind.t)
  ~(pieces : Piece.t Position.Map.t)
  : Position.t
  =
  List.random_element_exn
    (Tic_tac_toe_exercises_lib.available_moves ~game_kind ~pieces)
;;

(* Exercise 3.2.

   Implement a game AI that picks a random position, unless there is an
   available winning move.

   After you are done, update [compute_next_move] to use your
   [pick_winning_move_if_possible_strategy]. *)
let pick_winning_move_if_possible_strategy
  ~(me : Piece.t)
  ~(game_kind : Game_kind.t)
  ~(pieces : Piece.t Position.Map.t)
  : Position.t
  =
  let winning_moves =
    Tic_tac_toe_exercises_lib.winning_moves ~me ~game_kind ~pieces
  in
  if not (List.is_empty winning_moves)
  then List.random_element_exn winning_moves
  else random_move_strategy ~game_kind ~pieces
;;

(* disables unused warning. Feel free to delete once it's used. *)
let _ = pick_winning_move_if_possible_strategy

(* Exercise 4.2.

   Implement a game AI that picks a random position, unless there is an
   available winning move.

   After you are done, update [compute_next_move] to use your
   [pick_winning_move_if_possible_strategy]. *)
let pick_winning_move_or_block_if_possible_strategy
  ~(me : Piece.t)
  ~(game_kind : Game_kind.t)
  ~(pieces : Piece.t Position.Map.t)
  : Position.t
  =
  let winning_moves =
    Tic_tac_toe_exercises_lib.winning_moves ~me ~game_kind ~pieces
  in
  if not (List.is_empty winning_moves)
  then List.random_element_exn winning_moves
  else (
    let blocking_moves =
      Tic_tac_toe_exercises_lib.losing_moves ~me ~game_kind ~pieces
    in
    if not (List.is_empty blocking_moves)
    then List.random_element_exn blocking_moves
    else random_move_strategy ~game_kind ~pieces)
;;

let score
  ~(me : Piece.t)
  ~(game_kind : Game_kind.t)
  ~(pieces : Piece.t Position.Map.t)
  : float
  =
  match Tic_tac_toe_exercises_lib.evaluate ~game_kind ~pieces with
  | Game_over { winner = n } ->
    (match n with
     | None -> 0.0
     | Some p ->
       if Piece.equal p me then Float.infinity else Float.neg_infinity)
  | Game_continues -> 0.0 (* TODO: heuristic *)
  | Illegal_state -> failwith "score found an illegal state"
;;

(* stolen from other file, updated to actually change game state (bruh) *)
let place_piece (game : Game_state.t) ~piece ~position : Game_state.t =
  let pieces = Map.add_exn game.pieces ~key:position ~data:piece in
  let game_status =
    match
      Tic_tac_toe_exercises_lib.evaluate ~game_kind:game.game_kind ~pieces
    with
    | Game_over { winner = p } ->
      Game_status.Game_over
        { winner =
            (match p with
             | None -> None
             | Some p -> Some (p, Set.empty (module Position)))
        }
    | Game_continues -> Turn_of (Piece.flip piece)
    | Illegal_state -> failwith "place_piece encountered illegal state"
  in
  { game with pieces; game_status }
;;

(* if it's a tie i'm making the player X, hopefully that doesn't cause
   issues *)
let rec minimax (node : Game_state.t) player depth maximizing =
  let me =
    match node.game_status with
    | Turn_of p -> p
    | Game_status.Game_over { winner = n } ->
      (match n with None -> Piece.X | Some (p, _) -> p)
  in
  if depth = 0
     || match node.game_status with Turn_of _ -> false | _ -> true
  then score ~me:player ~game_kind:node.game_kind ~pieces:node.pieces
  else if maximizing
  then
    List.fold
      (List.map
         (Tic_tac_toe_exercises_lib.available_moves
            ~game_kind:node.game_kind
            ~pieces:node.pieces)
         ~f:(fun pos ->
         minimax
           (place_piece node ~piece:me ~position:pos)
           player
           (depth - 1)
           false))
      ~init:Float.neg_infinity
      ~f:Float.max
  else
    List.fold
      (List.map
         (Tic_tac_toe_exercises_lib.available_moves
            ~game_kind:node.game_kind
            ~pieces:node.pieces)
         ~f:(fun pos ->
         minimax
           (place_piece node ~piece:me ~position:pos)
           player
           (depth - 1)
           false))
      ~init:Float.infinity
      ~f:Float.min
;;

let minimax_strategy
  ~(me : Piece.t)
  ~(game_kind : Game_kind.t)
  ~(pieces : Piece.t Position.Map.t)
  ~(game_state : Game_state.t)
  : Position.t
  =
  (* let winning_moves = Tic_tac_toe_exercises_lib.winning_moves ~me
     ~game_kind ~pieces in if not (List.is_empty winning_moves) then
     List.random_element_exn winning_moves else ( *)
  (* let blocking_moves = Tic_tac_toe_exercises_lib.losing_moves ~me
     ~game_kind ~pieces in if not (List.is_empty blocking_moves) then
     List.random_element_exn blocking_moves else ( *)
  let available_moves =
    Tic_tac_toe_exercises_lib.available_moves ~game_kind ~pieces
  in
  let tmp =
    List.map available_moves ~f:(fun pos ->
      pos, minimax (place_piece game_state ~piece:me ~position:pos) me 4 true)
  in
  List.iter tmp ~f:(fun (x, y) ->
    print_endline (Position.to_string x ^ Float.to_string y));
  let max_ele =
    (fun y ->
      match y with None -> failwith "minimax broke :(" | Some (x, _) -> x)
      ((List.max_elt tmp) ~compare:(fun (_, x) (_, y) -> Float.compare x y))
  in
  print_endline (Position.to_string max_ele);
  max_ele
;;

let full_strategy
  ~(me : Piece.t)
  ~(game_kind : Game_kind.t)
  ~(pieces : Piece.t Position.Map.t)
  ~(game_state : Game_state.t)
  : Position.t
  =
  minimax_strategy ~me ~game_kind ~pieces ~game_state
;;

let _ = pick_winning_move_or_block_if_possible_strategy

(* [compute_next_move] is your Game AI's function.

   [game_ai.exe] will connect, communicate, and play with the game server,
   and will use [compute_next_move] to pick which pieces to put on your
   behalf.

   [compute_next_move] is only called whenever it is your turn, the game
   isn't yet over, so feel free to raise in cases where there are no
   available spots to pick. *)
let compute_next_move ~(me : Piece.t) ~(game_state : Game_state.t)
  : Position.t
  =
  full_strategy
    ~me
    ~game_kind:game_state.game_kind
    ~pieces:game_state.pieces
    ~game_state
;;
