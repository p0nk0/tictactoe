open! Core
open! Bonsai_web
open! Tic_tac_toe_2023_common
open! Protocol

val component
  :  navbar:Vdom.Node.t Value.t
  -> game_id:Game_id.t Value.t
  -> Vdom.Node.t Computation.t
