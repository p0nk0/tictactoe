open! Core
open Bonsai_web

val render_chip
  :  theme:View.Theme.t
  -> intent:View.Intent.t
  -> string
  -> Vdom.Node.t
