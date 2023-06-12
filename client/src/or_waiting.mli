open! Core

type 'a t =
  | Resolved of 'a
  | Waiting
[@@deriving sexp, equal]
