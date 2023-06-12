open! Core
open Bonsai_web

let button_role =
  (* NOTE: "role=button" is a way of signaling alternative ways of interacting like
     screenreaders + vimium that something is clickable. *)
  Vdom.Attr.many [ Style.pointer; Vdom.Attr.create "role" "button" ]
;;
