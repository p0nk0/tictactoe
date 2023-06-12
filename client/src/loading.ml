open! Core
open Bonsai_web

let vdom =
  View.hbox
    ~gap:(`Rem 0.5)
    [ Feather_icon.svg
        ~extra_attrs:[ Style.spin ]
        ~size:(`Rem 1.0)
        ~stroke:(`Var Style.For_referencing.navbar_fg)
        Feather_icon.Refresh_cw
    ]
;;

let animated_gradient = Vdom.Node.div ~attrs:[ Style.animated_gradient ] []
