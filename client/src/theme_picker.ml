open! Core
open Bonsai_web
open Bonsai.Let_syntax

let is_dark_var =
  Persistent_var.create
    (module Bool)
    `Local_storage
    ~unique_id:"js-tictactoe-is-dark"
    ~default:false
;;

let vdom =
  let is_dark = Persistent_var.value is_dark_var in
  let setter = Effect.of_sync_fun (Persistent_var.set is_dark_var) in
  let%sub theme = View.Theme.current in
  let%arr is_dark = is_dark
  and theme = theme in
  let color = (View.primary_colors theme).foreground in
  let icon =
    match is_dark with
    | true -> Feather_icon.Sun
    | false -> Feather_icon.Moon
  in
  let setter = Vdom.Attr.on_click (fun _ -> setter (not is_dark)) in
  let message = View.text [%string {|%{if is_dark then "Light" else "Dark"} theme|}] in
  View.vbox
    ~main_axis_alignment:Center
    ~cross_axis_alignment:Center
    ~attrs:[ Accessibility.button_role; setter; Style.navbar_icon ]
    [ View.hbox
        ~main_axis_alignment:Center
        ~cross_axis_alignment:Center
        [ Feather_icon.svg ~fill:color ~size:(`Rem 1.) icon; message ]
    ]
;;

let theme =
  let is_dark = Persistent_var.value is_dark_var in
  match%sub is_dark with
  | true -> Bonsai.const (Kado.theme ~style:Dark ~version:Bleeding ())
  | false -> Bonsai.const (Kado.theme ~style:Light ~version:Bleeding ())
;;
