open! Core
open! Bonsai_web

let image_to_show = List.random_element_exn Images.all

let error ~message =
  View.hbox
    ~gap:(`Rem 1.0)
    [ Images.vdom image_to_show
    ; View.vbox
        [ Vdom.Node.div
            ~attrs:[ Style.error_sad_face ]
            [ Vdom.Node.h3 [ View.text ":(" ] ]
        ; Vdom.Node.div [ View.text message ]
        ]
    ]
;;
