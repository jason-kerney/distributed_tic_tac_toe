# TTT

## Features Next

  * When a match stops, any game that was caused by the match stops
  * When a player stops, any Match they are in stops
  * Keep score of matches tied, won and lost
    * When a player stops any score they had is removed
  * Keep score of who has played whom and how many times.
  * Rank players based on wins and losses.
  * Match players to similarly ranked players
  * Determine winner of tournament.

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add tic_tak_toe to your list of dependencies in `mix.exs`:

        def deps do
          [{:tic_tak_toe, "~> 0.0.1"}]
        end

  2. Ensure tic_tak_toe is started before your application:

        def application do
          [applications: [:tic_tak_toe]]
        end
