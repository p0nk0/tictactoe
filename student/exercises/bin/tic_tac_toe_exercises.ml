open! Core
open! Tic_tac_toe_2023_common
open! Tic_tac_toe_exercises_lib
open! Protocol

let () =
  Command.group
    ~summary:"Tic Tac Toe exercises"
    [ "exercise-one", Tic_tac_toe_exercises_lib.exercise_one
    ; "exercise-two", Tic_tac_toe_exercises_lib.exercise_two
    ; "exercise-three", Tic_tac_toe_exercises_lib.exercise_three
    ; "exercise-four", Tic_tac_toe_exercises_lib.exercise_four
    ]
  |> Command_unix.run
;;
