# Tic-Tac-Toe

![Two Camels playing a game](./images/camels.jpg)

In these exercises you will learn about _adversarial games_ and 
game AIs to implement OCaml 🐫 bots that play [**tic-tac-toe**](https://en.wikipedia.org/wiki/Tic-tac-toe) and
[**Gomoku**](https://en.wikipedia.org/wiki/Gomoku).


In these exercises you will:
- _Play_ **TIC TAC TOE**!!
- _Write_ a bot to play **TIC TAC TOE**!!
- _Improve_ your **TIC TAC TOE bot**!!

## Background

_Tic-tac-toe_ is a game in which two players take turns in placing either
an `O` or an `X` in one square of a __3x3__ grid. The winner is the first
player to get __3__ of the same symbols in a row.

_Gomoku_ (also commonly referred to as "Omok"), is very similar to tic-tac-toe,
but __bigger__. Two players play on a 15x15 board and the winner is the first
player to get __5__ pieces in a row.

You can think of a digital tic-tac-toe board as a "mapping" of "position -> piece"
with the following types:

```ocaml
module Position = struct
  (* [position] in the board.
  
     (e.g. "top-left" cell is (row, column) (0, 0),
     and "bottom mid" cell is (2, 1)) *)
  type t =
    { row : int
    ; column : int
    }
end

module Piece = struct
  type t = 
    | X
    | O
end
```

For example, the board:

```
 X | - | - 
___|___|___
 - | O | X 
___|___|___
 - | O | - 
```

Can be represented as a mapping of:

```
(row, column)
  (0, 0) => X
  (1, 1) => O
  (1, 2) => X
  (2, 1) => O
```

### Exercise 0.0

What board does the following "mapping" represent? Is there anything interesting
happening? (Hint: If you were O, what move would you play?) Feel free to edit
the "Answer board" below:

```
(row, column)
  (1, 1) => X
  (0, 0) => O
  (0, 2) => O
  (2, 0) => X
  (2, 1) => X
  (2, 2) => O
```

Answer board:

```
 - | - | - 
___|___|___
 - | - | - 
___|___|___
 - | - | - 
```

After you've answered look for a fellow fellow near you and discuss your
answers!

## Prep Work

First, fork this repository by visiting [this
page](https://github.com/jane-street-immersion-program/tictactoe/fork) and clicking on the
green "Create fork" button at the bottom.

Then clone the fork locally (on your AWS machine) to get started. You can clone a repo on
the command line like this (where `$USER` is your GitHub username):

```sh
$ git clone git@github.com:$USER/tictactoe.git
Cloning into 'tictactoe'...
remote: Enumerating objects: 61, done.
remote: Counting objects: 100% (61/61), done.
remote: Compressing objects: 100% (57/57), done.
remote: Total 61 (delta 2), reused 61 (delta 2), pack-reused 0
Receiving objects: 100% (61/61), 235.81 KiB | 6.74 MiB/s, done.
Resolving deltas: 100% (2/2), done.
```

Now you should be able to enter into the project's directory, build the starter
code, and run the executable binary like this:

```sh
$ cd tictactoe
tictactoe$ dune build
tictactoe$ dune runtest
tictactoe$ dune exec student/bin/game_ai.exe help
Bot-running command

  game_ai.exe SUBCOMMAND

=== subcommands ===

  create-game-and-play       . Send off an rpc to create and game and then plays
                               the game, waiting for the other player to place
                               pieces
  create-game-and-play-against-self
                             . Send off an rpc to create and then immediately
                               start playing against itself
  join-game-and-play         . Send off an rpc to join a game and then randomly
                               places pieces using web socket rpc
  version                    . print version information
  help                       . explain a given subcommand (perhaps recursively)
```

> NOTE: If you are getting a problem like `Library "bonsai" not found.` raise
> your hand, and ask for help, and we'll help you install your dependencies!
> You might need to run `opam install $MISSING_LIBRARY`, but "opam" (OCaml's
> package manager) can be a bit weird at times, so please raise your hand!

## Directory Layout


The files for these exercises are located within the `student` directory:

```sh
tictactoe$ tree student
student
├── bin
│   ├── dune
│   ├── game_ai-help-for-review.org
│   ├── game_ai.ml
│   └── game_ai.mli
├── exercises
│   ├── bin
│   │   ├── dune
│   │   ├── tic_tac_toe_exercises-help-for-review.org
│   │   ├── tic_tac_toe_exercises.ml
│   │   └── tic_tac_toe_exercises.mli
│   └── src
│       ├── dune
│       ├── main.ml
│       └── main.mli
└── src
    ├── dune
    ├── tictactoe_game_ai.ml
    └── tictactoe_game_ai.mli

6 directories, 14 files
```

* `student/bin` contains the "game_ai" executable that you can use to run your bot.
* `student/exercises` and `student/src` are where you'll be implemting your bot.

### Game Server

There are other directories like `server`, `rpc-client`, and more. These directories
contain the "game server" that you can use to spectate your games!

You can run the game server by running the `./run-game-server.sh` script:

```
tictactoe$ ./run-game-server.sh 
Game server running on port 8080
```

You should then be able to navigate to: http://$YOUR_AWS_HOSTNAME:8080

> NOTE: You can find your AWS hostname/IP addres by running `$ hostname -I`
> TODO: Confirm that the above is true on the actual boxes.

You should see a game server site like this:

![Game Server](./images/game-server.jpg)

> NOTE: If you can't see the above site, do not worry! We have a **shared web server**
> hosted at here [todo](todo). It's hostname and port are: http://TODO_HOSTNAME:8181

## Exercises!


You can think of an AI that plays tic-tac-toe board as a "function" of type
`me:Piece.t -> game_state:Game_state.t -> Position.t`.

Where the `me` parameter is the "piece" that the bot is playing as, and
`Game_state.t` is the state of the board (where all of the pieces are, and also
the type of game you're playing (i.e. 3x3 tic-tac-toe vs. 15x15 Omok)), and the 
returned position is the place you've picked to put your position.

Over the course of these exercises you will be gradually such a function.

### Exercise 1

One question you might ask is: What if the game is already over? 
Has someone already won? Is there a tie? Is a piece ready to be
placed/does your place continue?


Your task for exercise 1 is implementing:

```ocaml
val evaluate : game_kind:Game_kind.t -> pieces:Piece.t Position.Map.t -> Evaluation.t
```

where evaluation has the type:

```ocaml
module Evaluation = struct
  type t =
    | Illegal_state
    | Game_over of { winner : Piece.t option }
    | Game_continues
end
```
You can implement this function in `student/exercises/src/main.ml`

Feel free to - _at first_ - ignore the [game_kind] parameter and assume that
it'll only work for tic-tac-toe, and not omok.

> HINT: [Map] is a new OCaml module that you have not seen before! It is
> OCaml's equivalent of python dictionaries, Java HashMap's or any languages's
> "map". Available functions can be found here:
> [Real World Ocaml](https://dev.realworldocaml.org/maps-and-hashtables.html).
> and on [ocaml.org's docs page](https://ocaml.org/u/c208440793aa1aa9d82e70e53cad6da8/base/v0.15.0/doc/Base/Map/index.html).
  > If map's/dictionaries are a new concept to you this is fine! Feel free to ask a TA
  > for help/ask on the #questions slack channel if something is unclear!

Here are some [*Map*] functions that you might find useful:

```ocaml
(** Returns [Some value] bound to the given [key], or [None] if none exists. *)
val find : ('k, 'v, 'cmp) Map.t -> 'k -> 'v option

(** [mem map key] tests whether map contains a binding for key. *)
val mem : ('k, _, 'cmp) t -> 'k -> bool
```

> NOTE: The type `('k, 'v, 'cmp) Map.t` means a map from with keys of type
> `'k` and values of type `'v`. For example, `(Position.t, Piece.t,
> Position.comparator_witness) Map.t` is a map from `Position.t` to `Piece.t`.
> The `'cmp` parameter is magical and you can mostly ignore it. If you're
> interested, read about it on the "Real World OCaml" link above or ask a TA!
> 
> Something else weird syntax-wise is that the type `(Position.t, Piece.t,
> Position.comparator_witness) Map.t` **is the same as**  `Piece.t Position.Map.t`.


Additionally, there are some functions that might be helpful available 
for operating on `Position.t`'s

```ocaml
module Position : sig
  (* Top-left is {row = 0; column = 0}. *)
  type t =
    { row : int
    ; column : int
    }

  val in_bounds : t -> game_kind:Game_kind.t -> bool
  val equal : t -> t -> bool
  
  (** [down t] is [t]'s downwards neighbor. *)
  val down : t -> t
  val right : t -> t
  val up : t -> t
  val left : t -> t


  (** [all_offsets] is a list of functions to compute all 8 neighbors of a
      cell (i.e. left, up-left, up, up-right, right, right-down, down,
      down-left). *)
  val all_offsets : (t -> t) list
end
```

> NOTE: [Position] is defined in `common/protocol.mli`.

### Exercise 2

Your AI _needs_ to make a choice of "which free available spot" it should
put it's piece on. Let's find "all free positions!". Implement `available_moves`
in `student/exercises/src/main.ml`

```ocaml
val available_moves : game_kind:Game_kind.t -> pieces:Piece.t Position.Map.t -> Position.t list
```

> HINT: Look for `Map.to_alist`/`Map.keys` in the [ocaml docs](https://ocaml.org/u/c208440793aa1aa9d82e70e53cad6da8/base/v0.15.0/doc/Base/Map/index.html), and also leverage `List.filter`.


TODO(j): write instructions for exercises 3+4

