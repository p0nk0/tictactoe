open! Core
open Bonsai_web

let render_chip ~theme ~intent text =
  let is_dark = (View.constants theme).is_dark in
  let { View.Fg_bg.foreground; background } =
    View.intent_colors theme intent
  in
  Vdom.Node.div
    ~attrs:
      [ Vdom.Attr.style
          Css_gen.(
            match is_dark with
            | true ->
              create_with_color ~field:"border-color" ~color:background
              @> color background
            | false ->
              create_with_color ~field:"border-color" ~color:foreground
              @> background_color background
              @> color foreground)
      ; Style.chip
      ]
    [ Vdom.Node.text text ]
;;
