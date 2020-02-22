urnitol
=======

Urn and ball simulator inspired by all the crazy probability models that use urns and colored balls


General
-------

Urn simulations are set up and run through UrnSimulators which consist of arrays of Urns and EventBins.  Urns start with populations of balls from one or more classes.  EventBins are structures where balls are collected and then acted upon in some way.

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
        balls:
          - class: black
            num: 0
          - class: white
            num: 0

    event_bins:
      - name: bin1
        balls:
          - class: black
            num: 0
          - class: white
            num: 0
        source_urns:
          - snuffy
        actions:
          - type: move
            urn: bird
            class: black
          - type: discard
            class: white


Dependencies
------------

* DataStructures
* Printf
* YAML
