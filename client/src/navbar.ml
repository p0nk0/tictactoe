open! Core
open! Bonsai_web
open Bonsai.Let_syntax
open Tic_tac_toe_2023_common
open Protocol
module Popover = Bonsai_web_ui_popover
module Form = Bonsai_web_ui_form

module No_td_padding_please =
[%css
stylesheet
  {|
  .target td {
     /* sorry >.> */
     padding-right: 0px !important;
  }
|}]

let component ~url ~set_url =
  let%sub theme = View.Theme.current in
  let%sub theme_picker = Theme_picker.vdom in
  let%sub me = Services.me in
  let%sub user =
    match%sub me with
    | Or_waiting.Waiting -> Bonsai.const Loading.vdom
    | Resolved me ->
      let%sub { wrap; open_; _ } =
        Bonsai_web_ui_popover.component
          ~close_when_clicked_outside:true
          ~direction:(Value.return Popover.Direction.Down)
          ~alignment:(Value.return Popover.Alignment.Center)
          ~popover:(fun ~close:_ ->
            let%sub form =
              let%sub form =
                Form.Elements.Textbox.string ~placeholder:"Username" ()
              in
              let%arr form = form in
              Form.project
                form
                ~parse_exn:Username.of_string
                ~unparse:Username.to_string
            in
            let%sub form = Form.Dynamic.with_default me form in
            let%sub theme = View.Theme.current in
            let%arr form = form
            and me = me
            and theme = theme in
            let data = Form.value_or_default ~default:me form in
            View.hbox
              ~attrs:[ No_td_padding_please.target ]
              ~gap:(`Rem 0.5)
              ~main_axis_alignment:Center
              [ Form.view_as_vdom
                  form
                  ~theme
                  ~on_submit:
                    (Form.Submit.create
                       ~button:None
                       ~handle_enter:true
                       ()
                       ~f:(fun data -> Services.set_me data))
              ; View.button
                  ~attrs:
                    (match Username.equal data me with
                     | true -> [ Vdom.Attr.disabled ]
                     | false -> [])
                  theme
                  ~on_click:(Services.set_me data)
                  "change"
              ])
          ()
      in
      let%arr wrap = wrap
      and open_ = open_
      and me = me in
      wrap
        (View.hbox
           ~cross_axis_alignment:Center
           ~gap:(`Rem 0.5)
           ~attrs:
             [ Style.pointer
             ; Accessibility.button_role
             ; Vdom.Attr.on_click (fun _ -> open_)
             ]
           [ Vdom.Node.span
               [ Vdom.Node.strong [ View.text "I am: " ]
               ; View.text (Username.to_string me)
               ]
           ; Feather_icon.svg ~size:(`Rem 1.0) Edit
           ])
  in
  let%arr theme_picker = theme_picker
  and _url = url
  and theme = theme
  and user = user in
  let is_dark = (View.constants theme).is_dark in
  View.hbox
    ~cross_axis_alignment:Stretch
    ~main_axis_alignment:Space_between
    [ View.hbox
        ~cross_axis_alignment:Center
        ~gap:(`Em 1)
        [ View.hbox
            ~cross_axis_alignment:Center
            ~gap:(`Em 1)
            ~attrs:
              [ Accessibility.button_role
              ; Vdom.Attr.on_click (fun _ -> set_url Page.Homepage)
              ]
            [ Feather_icon.svg
                ~stroke:
                  (match is_dark with
                   | true -> `Name "white"
                   | false -> `Name "black")
                ~size:(`Rem 2.0)
                Hash
            ; View.text ~attrs:[ Style.bold; Style.no_select ] "Tic Tac Toe"
            ]
        ]
    ; View.hbox
        ~cross_axis_alignment:Center
        ~gap:(`Em 1)
        [ user; theme_picker ]
    ]
;;
