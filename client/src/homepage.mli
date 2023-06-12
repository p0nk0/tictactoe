open! Core
open! Bonsai_web

val component
  :  set_url:(Page.t -> unit Effect.t)
  -> navbar:Vdom.Node.t Value.t
  -> Vdom.Node.t Computation.t
