open! Core
open! Bonsai_web
open! Tic_tac_toe_2023_common
open! Tic_tac_toe_2023_common.Protocol
open Bonsai.Let_syntax

let image = List.random_element_exn Images.all

let banner ~set_url:_ _ =
  View.vbox
    ~gap:(`Em 1)
    ~cross_axis_alignment:Center
    ~attrs:[ Style.banner ]
    [ View.vbox
        ~cross_axis_alignment:Center
        [ Vdom.Node.h2 [ View.text "JSIP Game AI Week" ]; Images.vdom image ]
    ; View.text (Images.description image)
    ]
;;

let create_column ~strong_word ~content =
  Vdom.Node.div
    ~attrs:[ Style.homepage_column ]
    [ Vdom.Node.div
        [ Vdom.Node.span
            [ Vdom.Node.strong [ View.text ([%string "%{strong_word}"] ^ " ") ]
            ; View.text "game"
            ]
        ]
    ; Vdom.Node.div [ content ]
    ]
;;

let game_kind_form =
  let%sub selected_game, set_selected_game = Bonsai.state Game_kind.Tic_tac_toe in
  let%sub tic_tac_toe_button, omok_button =
    let%sub theme = View.Theme.current in
    let%arr selected_game = selected_game
    and set_selected_game = set_selected_game
    and theme = theme in
    let intent_for_game = function
      | Game_kind.Omok -> View.Intent.Info
      | Tic_tac_toe -> View.Intent.Success
    in
    let create_button ~game =
      View.button
        theme
        ~intent:(intent_for_game game)
        ~on_click:(set_selected_game game)
        ~attrs:
          (match Game_kind.equal selected_game game with
           | false -> []
           | true -> [ Kado.Unstable.Buttons.pressed; Style.pressed_button ])
        (Game_kind.sexp_of_t game
         |> Sexp.to_string
         |> String.lowercase
         |> String.map ~f:(function
           | '_' -> ' '
           | x -> x))
    in
    create_button ~game:Tic_tac_toe, create_button ~game:Omok
  in
  let%sub theme = View.Theme.current in
  let%arr selected_game = selected_game
  and tic_tac_toe_button = tic_tac_toe_button
  and omok_button = omok_button
  and theme = theme in
  ( selected_game
  , View.card'
      theme
      ~title_kind:Discreet
      ~title:[ Vdom.Node.text "Game kind" ]
      [ Vdom.Node.div
          ~attrs:[ Kado.Unstable.Buttons.vertical_group ]
          [ tic_tac_toe_button; omok_button ]
      ] )
;;

let against_form =
  let%sub selected_against, set_selected_against = Bonsai.state None in
  let%sub buttons =
    let%sub theme = View.Theme.current in
    let%arr selected_against = selected_against
    and set_selected_against = set_selected_against
    and theme = theme in
    let intent_for_against = function
      | None -> View.Intent.Info
      | Some Difficulty.Easy -> View.Intent.Success
      | Some Medium -> View.Intent.Warning
      | Some Hard -> View.Intent.Error
    in
    let create_button ~against =
      View.button
        theme
        ~intent:(intent_for_against against)
        ~on_click:(set_selected_against against)
        ~attrs:
          (match [%equal: Difficulty.t option] selected_against against with
           | false -> []
           | true -> [ Kado.Unstable.Buttons.pressed; Style.pressed_button ])
        (match against with
         | None -> "human"
         | Some difficulty ->
           Difficulty.sexp_of_t difficulty |> Sexp.to_string |> String.lowercase)
    in
    [ None; Some Difficulty.Easy; Some Medium; Some Hard ]
    |> List.map ~f:(fun against -> create_button ~against)
  in
  let%sub theme = View.Theme.current in
  let%arr selected_against = selected_against
  and buttons = buttons
  and theme = theme in
  ( selected_against
  , View.card'
      theme
      ~title_kind:Discreet
      ~title:[ Vdom.Node.text "Game kind" ]
      [ Vdom.Node.div ~attrs:[ Kado.Unstable.Buttons.vertical_group ] buttons ] )
;;

let create_game_button ~set_url ~game_kind ~against =
  let%sub me = Services.me in
  let%sub send_create_game_rpc =
    Rpc_effect.Rpc.dispatcher Create_game.rpc ~where_to_connect:Self
  in
  let%sub theme = View.Theme.current in
  match%sub me with
  | Or_waiting.Waiting -> Bonsai.const Loading.vdom
  | Resolved username ->
    let%arr theme = theme
    and game_kind = game_kind
    and against = against
    and username = username
    and send_create_game_rpc = send_create_game_rpc in
    View.button
      theme
      ~on_click:
        (let%bind.Effect response =
           send_create_game_rpc
             { With_username.username; txt = { game_kind; against_server_bot = against } }
         in
         match response with
         | Error error ->
           Effect.print_s [%message "Error while creating game" (error : Error.t)]
         | Ok game_id ->
           (match against with
            | None -> Effect.Ignore
            | Some _ -> set_url (Page.Game game_id)))
      "Create!"
;;

let create_game_section ~set_url =
  let%sub game_kind, game_kind_vdom = game_kind_form in
  let%sub against, against_vdom = against_form in
  let%sub create_game_button = create_game_button ~game_kind ~against ~set_url in
  let%arr game_kind_vdom = game_kind_vdom
  and against_vdom = against_vdom
  and create_game_button = create_game_button in
  View.vbox
    ~attrs:[ Style.create_game_section ]
    [ View.hbox ~gap:(`Rem 0.5) [ game_kind_vdom; against_vdom ]; create_game_button ]
;;

let render_player player = View.text (Rendering_utils.player_to_string player)

let joinable_games_columns
  : join_game:(Game_id.t -> unit Effect.t) option -> Joinable_game.t View.Table.Col.t list
  =
  fun ~join_game ->
  [ View.Table.Col.make
      "id"
      ~get:(fun joinable_game -> joinable_game.Joinable_game.game_id)
      ~render:(fun _theme id -> View.textf "%d" (Game_id.to_int id))
  ; View.Table.Col.make
      "proposer"
      ~get:(fun joinable_game -> joinable_game.Joinable_game.player_x)
      ~render:(fun _theme proposer -> render_player proposer)
  ; View.Table.Col.make
      "game kind"
      ~get:(fun joinable_game -> joinable_game.Joinable_game.game_kind)
      ~render:(fun theme game_kind -> Rendering_utils.render_game_kind theme game_kind)
  ; View.Table.Col.make
      "join"
      ~get:(fun joinable_game -> joinable_game.Joinable_game.game_id)
      ~render:(fun theme id ->
        match join_game with
        | None -> Vdom.Node.none
        | Some join_game ->
          let constants = View.constants theme in
          Feather_icon.svg
            ~extra_attrs:
              [ Accessibility.button_role; Vdom.Attr.on_click (fun _ -> join_game id) ]
            ~size:(`Rem 1.0)
            ~fill:constants.primary.foreground
            Play)
  ]
;;

let joinable_games ~set_url =
  let%sub joinable_games = Services.joinable_games in
  match%sub joinable_games with
  | Waiting -> Bonsai.const Loading.animated_gradient
  | Resolved joinable_games ->
    let%sub join_game =
      let%sub me = Services.me in
      match%sub me with
      | Or_waiting.Waiting -> Bonsai.const None
      | Resolved me ->
        let%sub join_game =
          Rpc_effect.Rpc.dispatcher ~where_to_connect:Self Join_existing_game.rpc
        in
        let%arr me = me
        and join_game = join_game in
        Some
          (fun game_id ->
             match%bind.Effect join_game { username = me; txt = game_id } with
             | Error error ->
               Effect.print_s
                 [%message "error while trying to join game!" (error : Error.t)]
             (* TODO: Maybe show nice errors in a toast/something else. *)
             | Ok ((Game_does_not_exist | Game_already_full | Game_already_ended) as error)
               ->
               Effect.print_s
                 [%message
                   "App-level error occurred." (error : Join_existing_game.Response.t)]
             | Ok (Ok | You've_already_joined_this_game) -> set_url (Page.Game game_id))
    in
    let%sub theme = View.Theme.current in
    let%arr joinable_games = joinable_games
    and join_game = join_game
    and theme = theme in
    View.Table.render
      ~table_attrs:[ Style.table_full_width ]
      ~row_attrs:(fun joinable_game ->
        match join_game with
        | None -> []
        | Some join_game ->
          [ Vdom.Attr.on_click (fun _ -> join_game joinable_game.Joinable_game.game_id)
          ; Style.clickable_row
          ])
      theme
      (joinable_games_columns ~join_game)
      (Map.data joinable_games |> List.rev)
;;

let watchable_games_column
  :  am_i_playing:(Game_state.t -> bool) -> set_url:(Page.t -> unit Effect.t)
    -> Game_state.t View.Table.Col.t list
  =
  fun ~am_i_playing ~set_url ->
  [ View.Table.Col.make
      "id"
      ~get:(fun game_state -> game_state.Game_state.game_id)
      ~render:(fun _theme game_id -> View.textf "%d" (Game_id.to_int game_id))
  ; View.Table.Col.make
      "watch"
      ~get:(fun game_state -> game_state.Game_state.game_id)
      ~render:(fun theme game_id ->
        let constants = View.constants theme in
        Feather_icon.svg
          ~extra_attrs:
            [ Accessibility.button_role
            ; Vdom.Attr.on_click (fun _ -> set_url (Page.Game game_id))
            ]
          ~size:(`Rem 1.0)
          ~stroke:constants.primary.foreground
          Eye)
  ; View.Table.Col.make
      "game"
      ~get:(fun game_state ->
        ( game_state.Game_state.player_x
        , game_state.player_o
        , game_state.game_kind
        , game_state.pieces ))
      ~render:(fun theme (player_x, player_o, game_kind, pieces) ->
        View.hbox
          ~gap:(`Rem 1.0)
          ~cross_axis_alignment:Center
          [ Vdom.Node.div
              [ View.textf
                  "%s vs. %s"
                  (Rendering_utils.player_to_string player_x)
                  (Rendering_utils.player_to_string player_o)
              ]
          ; Rendering_utils.render_game_kind theme game_kind
          ; View.textf "%d turns" (Map.length pieces)
          ])
  ; View.Table.Col.make "status" ~get:Fn.id ~render:(fun theme game_state ->
      match am_i_playing game_state with
      | false -> Rendering_utils.render_game_status game_state
      | true -> Chip.render_chip ~theme ~intent:Success "Your turn!")
  ]
;;

let watchable_games ~set_url =
  let%sub games_with_two_players = Services.games_with_two_players in
  match%sub games_with_two_players with
  | Waiting -> Bonsai.const Loading.animated_gradient
  | Resolved games_with_two_players ->
    let%sub theme = View.Theme.current in
    let%sub am_i_playing =
      let%sub me = Services.me in
      let%arr me = me in
      fun game_state ->
        match me with
        | Waiting -> false
        | Resolved me ->
          (match game_state.Game_state.game_status with
           | Game_over _ -> false
           | Turn_of piece ->
             let player = Game_state.get_player ~piece game_state in
             Player.equal player (Player me))
    in
    let%arr games_with_two_players = games_with_two_players
    and theme = theme
    and am_i_playing = am_i_playing in
    View.Table.render
      ~table_attrs:[ Style.table_full_width ]
      ~row_attrs:(fun game_state ->
        [ Vdom.Attr.on_click (fun _ -> set_url (Page.Game game_state.Game_state.game_id))
        ; Style.clickable_row
        ; (match game_state.game_status with
           | Game_over _ -> Style.finished_game
           | _ -> Vdom.Attr.empty)
        ])
      theme
      (watchable_games_column ~am_i_playing ~set_url)
      (Map.data games_with_two_players
       |> List.sort ~compare:(fun a b ->
         Comparable.lexicographic
           [ (fun a b ->
               Comparable.lift
                 Int.ascending
                 ~f:(fun game_state ->
                   match game_state.Game_state.game_status with
                   | Game_status.Game_over _ -> 1
                   | _ -> 0)
                 a
                 b)
           ; (fun a b ->
                Comparable.lift
                  (Comparable.reverse Game_id.compare)
                  ~f:(fun game_state -> game_state.Game_state.game_id)
                  a
                  b)
           ]
           a
           b))
;;

let component ~set_url ~navbar =
  let%sub create_game_section = create_game_section ~set_url in
  let%sub joinable_games = joinable_games ~set_url in
  let%sub watchable_games = watchable_games ~set_url in
  let%map.Computation theme = View.Theme.current
  and navbar = return navbar
  and create_game_section = return create_game_section
  and joinable_games = return joinable_games
  and watchable_games = return watchable_games in
  Vdom.Node.div
    ~attrs:[ Style.grid_container ]
    [ Vdom.Node.div ~key:"navbar" ~attrs:[ Style.grid_item_navbar ] [ navbar ]
    ; Vdom.Node.div ~attrs:[ Style.grid_item_entire_content ] [ banner ~set_url theme ]
    ; Vdom.Node.div
        ~attrs:[ Style.vsplit3; Style.grid_item_entire_content_level_2 ]
        [ create_column ~strong_word:"Create" ~content:create_game_section
        ; create_column ~strong_word:"Join" ~content:joinable_games
        ; create_column ~strong_word:"Watch" ~content:watchable_games
        ]
    ]
;;
