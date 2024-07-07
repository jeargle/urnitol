urnitol
=======

Urn and ball simulator inspired by all the crazy probability models that use urns and colored balls


General
-------

Urn and ball models are used as simple probabilistic systems that are easy to describe and think about.  The basic idea is that you start with a set of urns, and each urn can contain zero or more colored balls.  Then someone picks an urn and pulls a random ball out.  At that point they see the ball's color and take a further action that may or may not depend on the color.

For example, you could simulate a die by having one urn that contains 6 balls where each ball is a different color.  Then a round would be "pull with replacement" where you select a ball, note its color, and then put it back in the urn.

In urnitol Urn simulations are set up and run through UrnSimulators which consist of arrays of Urns and EventBins.  Urns start with populations of balls from one or more classes.  EventBins are structures where balls are collected and then acted upon in some way.

So the 2-step simulation loop goes:

1. pull - pull balls from Urns and place in EventBins
2. action - act on the EventBin balls

Currently supported EventBin actions are: move, discard, and double.


Setup File
----------

Setup files are YAML and specify the number of steps to simulate (`num_steps`), the initial structure of the Urns (`urns`), and the EventBins (`event_bins`) along with the actions they should implement.

Example YAML setup file:

    num_steps: 20

    urns:
      - name: snuffy
        balls:
          - class: black
            num: 30
          - class: white
            num: 30
      - name: bird

    event_bins:
      - name: bin1
        source_urns:
          - snuffy
        actions:
          - type: move
            target_urns: bird
            class: black
          - type: discard
            class: white

This file specifies two Urns with the names "snuffy" and "bird".  Snuffy has 30 black balls and 30 white balls while bird has none.  There is a single EventBin that randomly pulls balls from snuffy and then either moves them to bird if they are black or discards them if they are white.

An Urn must have a specified `name`.  `balls` only need to be set up if an Urn starts out containing balls.  Ball parameters do not limit what classes of balls may be added to the Urn during a simulation.  Ball specifications, if they exist, must include a `class` name.  If no `num` is set, it is assumed to be 0.

An EventBin must have a specified `name`.  The `source_urns` parameter can consist of a single Urn, a list of Urns, or the string "all".  If `source_urns: all`, then every Urn can be chosen during the pull stage.  The `source_odds` parameter can be set to "even" or "proportional", but it defaults to "even".  "even" `source_odds` means the probability that an Urn is chosen during the pull stage will be even across all `source_urns`.  With `source_odds: proportional`, the probability an Urn is chosen will be proportional to the number of balls it contains.

The `actions` parameter sets up Actions that will happen to pulled balls.  If a `class` is specified, the action will only apply to balls of that class.  An Action must have a `type` set.  These can be "move" or "discard", to move a pulled ball to a chosen target Urn or discard the ball, respectively.  "move" Actions must have a `target_urns` parameter, but this is optional for "discard" Actions.  If a "discard" Action has `target_urns` set up, it will act essentially like a "move" Action.  These `target_urns` will be Urns that pulled balls can be moved to.  `target_urns` can be set to the name of a single Urn, a list of Urn names, "all", "source", or "not source".  "source" will move pulled balls back to the Urn they were pulled from.  "not source" will move balls to an Urn other than the source Urn.  Finally, Actions can take a `target_odds` parameter (default "even") that can be either "even" or "proportional".  This is similar to the `source_odds` parameter but applies to the action stage of "move" Actions.

Dependencies
------------

* ArgParse
* CSV
* DataFrames
* DataStructures
* Plots
* Printf
* YAML
