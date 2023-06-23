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
tictactoe$ _build/default/student/bin/game_ai.exe --help
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

