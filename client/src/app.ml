open! Core
open! Bonsai_web
open! Tic_tac_toe_2023_common
open Bonsai.Let_syntax

let fades = "#EECE13", "#B210FF"

let set_vars theme =
  let constants = View.constants theme in
  let fade_from, fade_to = fades in
  let open Css_gen.Color in
  Style.Variables.set
    ~navbar_bg:(to_string_css constants.View.Constants.extreme.background)
    ~navbar_fg:(to_string_css constants.extreme.foreground)
    ~fade_from
    ~fade_to
    ()
;;

let body ~url ~set_url ~navbar =
  match%sub url with
  | Page.Homepage -> Homepage.component ~set_url ~navbar
  | Game game_id -> Game_page.component ~game_id ~navbar
;;

let component ~url ~set_url =
  let%sub navbar = Navbar.component ~url ~set_url in
  let%map.Computation vars =
    let%sub theme = View.Theme.current in
    let%arr theme = theme in
    set_vars theme
  and body = body ~url ~set_url ~navbar in
  View.vbox ~attrs:[ vars ] [ body ]
;;

let component ~random_image ~url ~set_url =
  let%sub theme = Theme_picker.theme in
  Services.start_services
    ~random_image
    (Bonsai_web.View.Theme.set_for_app theme (component ~url ~set_url))
;;
