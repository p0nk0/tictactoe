open! Core
open Bonsai_web

type t =
  | Capybara
  | Abstract_camels
  | Camel_v_robot
  | Capybara_v_camel
  | Camel_v_camel
[@@deriving enumerate]

val src : t -> string
val description : t -> string
val vdom : t -> Vdom.Node.t
