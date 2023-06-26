open! Core
open! Bonsai_web
open! Tic_tac_toe_2023_common
open! Protocol
open Bonsai.Let_syntax

let is_it_my_turn ~game_state =
  let%sub me = Services.me in
  let%arr ({ Game_state.game_status; _ } as game_state) = game_state
  and me = me in
  match me with
  | Or_waiting.Waiting -> false
  | Resolved me ->
    (match game_status with
     | Game_over _ -> false
     | Turn_of piece ->
       (match Game_state.get_player ~piece game_state with
        | Server_bot _ -> false
        | Player username -> Username.equal me username))
;;

let did_i_win ~game_state =
  let%sub me = Services.me in
  let%arr ({ Game_state.game_status; _ } as game_state) = game_state
  and me = me in
  match me with
  | Or_waiting.Waiting -> false
  | Resolved me ->
    (match game_status with
     | Game_over { winner = Some (piece, _positions) } ->
       let winning_player = Game_state.get_player game_state ~piece in
       Player.equal winning_player (Player me)
     | Game_over { winner = None } | Turn_of _ -> false)
;;

let render_title ~(game_state : Game_state.t Value.t) =
  let%sub is_thinking =
    let%sub { game_id; _ } = return game_state in
    Services.is_thinking ~game_id
  in
  let%sub is_it_my_turn = is_it_my_turn ~game_state in
  let%sub did_i_win = did_i_win ~game_state in
  let%sub theme = View.Theme.current in
  let%sub title =
    let%arr ({ player_x; player_o; game_kind; _ } as game_state) = game_state
    and theme = theme
    and is_it_my_turn = is_it_my_turn
    and did_i_win = did_i_win
    and is_thinking = is_thinking in
    View.vbox
      [ View.hbox
          ~cross_axis_alignment:Center
          ~gap:(`Rem 0.5)
          [ Vdom.Node.h2
              [ View.textf
                  "%s vs. %s"
                  (Rendering_utils.player_to_string player_x)
                  (Rendering_utils.player_to_string player_o)
              ]
          ; Rendering_utils.render_game_kind theme game_kind
          ; (match is_it_my_turn, did_i_win with
             | false, false -> Rendering_utils.render_game_status game_state
             | true, _ ->
               Chip.render_chip ~theme ~intent:Warning "Your turn!"
             | _, true -> Chip.render_chip ~theme ~intent:Success "You win!")
          ; (match is_thinking with
             | true -> Loading.vdom
             | false -> Vdom.Node.none)
          ]
      ]
  in
  return title
;;

let render_board ~(game_state : Game_state.t Value.t) =
  let%sub is_it_my_turn = is_it_my_turn ~game_state in
  let%sub maybe_take_turn_attr =
    match%sub is_it_my_turn with
    | false -> Bonsai.const (fun _ -> Vdom.Attr.empty)
    | true ->
      let%sub take_turn = Services.take_turn in
      (match%sub take_turn with
       | Waiting -> Bonsai.const (fun _ -> Vdom.Attr.empty)
       | Resolved take_turn ->
         let%arr take_turn = take_turn
         and { game_id; _ } = game_state in
         fun position ->
           Vdom.Attr.many
             [ Vdom.Attr.on_click (fun _ -> take_turn ~game_id position)
             ; Accessibility.button_role
             ; Style.clickable_cell
             ])
  in
  let%sub all_positions =
    let%arr { game_kind; _ } = game_state in
    let board_length = Game_kind.board_length game_kind in
    let%bind.List row = List.init board_length ~f:Fn.id in
    let%map.List column = List.init board_length ~f:Fn.id in
    { Position.row; column }
  in
  let%sub theme = View.Theme.current in
  let%arr { game_kind; pieces; game_status; _ } = game_state
  and all_positions = all_positions
  and theme = theme
  and maybe_take_turn_attr = maybe_take_turn_attr
  and is_it_my_turn = is_it_my_turn in
  let constants = View.constants theme in
  let game_board_attribute =
    match game_kind with
    | Omok -> Style.omok_board
    | Tic_tac_toe -> Style.tic_tac_toe_board
  in
  let cells =
    List.map all_positions ~f:(fun position ->
      let content =
        match Map.find pieces position with
        | None ->
          (match is_it_my_turn with
           | false -> Vdom.Node.none
           | true ->
             Vdom.Node.div
               ~attrs:[ Style.ghost_piece ]
               [ Feather_icon.svg
                   ~size:(`Rem 2.5)
                   ~stroke:constants.primary.foreground
                   (match game_status with
                    | Turn_of X -> X
                    | Turn_of O -> Circle
                    | Game_over _ ->
                      (* Illegal state is representable :( *)
                      X)
               ])
        | Some X ->
          Feather_icon.svg
            ~size:(`Rem 2.5)
            ~stroke:constants.primary.foreground
            X
        | Some O ->
          Feather_icon.svg
            ~size:(`Rem 2.5)
            ~stroke:constants.primary.foreground
            Circle
      in
      let maybe_take_turn_attr =
        match Map.find pieces position with
        | Some (X | O) -> Vdom.Attr.empty
        | None -> maybe_take_turn_attr position
      in
      let is_winning_game_cell =
        match game_status with
        | Turn_of _ | Game_over { winner = None } -> Vdom.Attr.empty
        | Game_over { winner = Some (_, winning_pieces) } ->
          (match Set.mem winning_pieces position with
           | false -> Vdom.Attr.empty
           | true -> Style.winning_game_cell)
      in
      Vdom.Node.div
        ~attrs:
          [ Style.game_cell; is_winning_game_cell; maybe_take_turn_attr ]
        [ content ])
  in
  Vdom.Node.div ~attrs:[ game_board_attribute ] cells
;;

let body ~game_id =
  let%sub game = Services.get_game ~game_id in
  match%sub game with
  | Or_waiting.Waiting -> Bonsai.const Loading.animated_gradient
  | Resolved game ->
    (match%sub game with
     | Game_id_does_not_exist ->
       let%arr game_id = game_id in
       Vdom.Node.div
         ~attrs:[ Style.game_error_page ]
         [ Error_page.error
             ~message:[%string "Game '%{game_id#Game_id}' does not exist!"]
         ]
     | Waiting_for_someone_to_join joinable_game ->
       let%arr { game_id; _ } = joinable_game in
       Vdom.Node.div
         ~attrs:[ Style.game_error_page ]
         [ Error_page.error
             ~message:
               [%string
                 "Game '%{game_id#Game_id}' is waiting for someone to join!"]
         ]
     | Both_players game_state ->
       let%sub title = render_title ~game_state in
       let%sub board = render_board ~game_state in
       let%arr board = board
       and title = title in
       View.vbox
         ~gap:(`Rem 0.5)
         ~cross_axis_alignment:Center
         [ Vdom.Node.div
             [ Vdom.Node.div ~attrs:[ Style.full_width ] [ title ]
             ; Vdom.Node.div
                 ~attrs:[ Style.surrounding_game_wrapper ]
                 [ board ]
             ]
         ])
;;

let component ~navbar ~game_id =
  let%sub body = body ~game_id in
  let%arr navbar = navbar
  and body = body in
  Vdom.Node.div
    ~attrs:[ Style.grid_container ]
    [ Vdom.Node.div
        ~key:"navbar"
        ~attrs:[ Style.grid_item_navbar ]
        [ navbar ]
    ; Vdom.Node.div ~attrs:[ Style.grid_item_levels_2_and_3 ] [ body ]
    ]
;;
