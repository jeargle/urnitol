urnitol
=======

Urn and ball simulator inspired by all the crazy probability models that use urns and colored balls


General
-------

Urn and ball models are used as simple probabilistic systems that are easy to describe and think about.  The basic idea is that you start with a set of urns, and each urn can contain zero or more colored balls.  Then someone picks an urn and pulls a random ball out.  At that point they see the ball's color and take a further action that may or may not depend on the color.

For example, you could simulate a die by having one urn that contains 6 balls where each ball is a different color.  Then a round would be "pull with replacement" where you select a ball, note its color, and then put it back in the urn.

In urnitol Urn simulations are set up and run through UrnSimulators which consist of arrays of Urns and EventBins.  Urns start with populations of balls from one or more classes.  EventBins are structures where balls are collected and then acted upon in some way.

So the 2-step simulation loop goes:

1. pull balls from Urns and place in EvenBins
2. act on the EvenBin balls

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
            urn: bird
            class: black
          - type: discard
            class: white

This file specifies two Urns with the names "snuffy" and "bird".  Snuffy has 30 black balls and 30 white balls while bird has none.  There is a single EventBin that randomly pulls balls from snuffy and then either moves them to bird if they are black or discards them if they are white.

Dependencies
------------

* DataStructures
* Printf
* YAML
