# TTT

## Features Next

  1. When a player stops, any Match they are in stops
  2. When a game stops, the Match is notified.
      1. If all the players are available then start a new game
      2. If any players are gone the match terminates
  3. Keep score of matches tied, won and lost
  4. Keep score of who has played whom and how many times.
  5. Rank players based on wins and losses.
  6. Match players to similarly ranked players
  7. Determine winner of tournament. 

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
