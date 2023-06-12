open! Core
open! Bonsai_web

val component
  :  random_image:Images.t
  -> url:Page.t Value.t
  -> set_url:(Page.t -> unit Effect.t)
  -> Vdom.Node.t Computation.t
