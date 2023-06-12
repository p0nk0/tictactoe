open! Core
open Tic_tac_toe_2023_common
open Protocol

(** The [Page] module represents the structure of your sites URL and is
    ursed for URL routing for your site. *)

type t =
  | Homepage
  | Game of Game_id.t
[@@deriving sexp, equal]

val parser : t Uri_parsing.Versioned_parser.t
