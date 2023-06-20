open! Core
open! Tic_tac_toe_2023_common
open! Tic_tac_toe_exercises_lib
open! Protocol

let () =
  Command.group
    ~summary:"Tic Tac Toe exercises"
    [ "exercise-one", Main.exercise_one
    ; "exercise-two", Main.exercise_two
    ; "exercise-three", Main.exercise_three
    ; "exercise-four", Main.exercise_four
    ]
  |> Command_unix.run
;;
