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


Dependencies
------------

* DataStructures
* Printf
* YAML
