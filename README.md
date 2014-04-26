Mastermind Miniproject Simulation
=================================

This is a simulation of a mastermind variation which is intended to be used for
comparing mastermind strategies.

This repository contains implementations in Lua, Haskell and Java. I've written
a [blog post](http://www.eugenkiss.com/b/experience-report-a-mastermind-simulation-in-lua-java-haskell/) comparing the solutions. The code is from 2011. There were originally three
separate repositories but I decided to merge them into one — yes, almost four
years later :P.


Motivation
----------

This simulation emerged because of a university project where Lego Mindstorm
robots were supposed to play a mastermind variation in an enclosed area.
*Writing this simulation was not the task*. However it was helpful in
determining a good strategy. The following text is an extract from the actual
university task:

### Task

An autonomous service robot is to be created that approaches as efficiently as
possible certain destinations in an enclosed area. Based on information it
receives at these destinations the robot is supposed to solve a logical task.
Analogous to mastermind sequences of buttons are to be figured out.


#### World

The robots move in an even, quadratic environment which is confinend with
walls. Eight buttons in known destinations are located in these walls.

The origin of ordinates is in the center of this world with wall length 1964mm
(the most right point thus is `(982, 0)`, the most left point `(-982, 0)`).
The centers of the buttons are in the following positions:

                                          1                    2
                                 +--------------------------------------+
                                 |      +---+                +---+      |
                                 |                                      |
                                 |                                      |
                                 |+                                    +|
                               0 ||                                    || 3
    T[0] = {x=-460, y=982},      |+                                    +|
    T[1] = {x=460, y=982},       |                                      |
    T[2] = {x=982, y=460},       |                y ^                   |
    T[3] = {x=982, y=-460},      |                  |                   |
    T[4] = {x=460, y=-982},      |                  |                   |
    T[5] = {x=-460, y=-982},     |                  +---->              |
    T[6] = {x=-982, y=-460},     |                       x              |
    T[7] = {x=-982, y=460}       |+                                    +|
                               7 ||                                    || 4
                                 |+                                    +|
                                 |                                      |
                                 |                                      |
                                 |      +---+                +---+      |
                                 +--------------------------------------+
                                          6                    5


#### Robot

The autonomous robot is supposed to figure out as many correct button sequences
as possible in a limited amount of time. The length of the sequence can be
between one and eight. An exemplary button sequence of length four is `(T[1],
T[6], T[3], T[1])`. Once the required number of buttons is activated through
bumping the robot receives the characteristic mastermind information:

1. How many buttons were activated in the correct position (`blacks`)
2. How many buttons are in the secret code but were activated in the wrong
   position (`whites`)

Once the robot activated the buttons in the correct order the sequence pertains
recognized. For every correct sequence points are received. As long as the time
has not expired the robot shall try to solve another secret sequence.


##### Example

Let `(T[0], T[6], T[3], T[1])` be the secret code. The buttons `(T[1], T[6],
T[4], T[3])` have been activated. Therefore `blacks = 1` and `whites = 2`.


Sources
-------

Part of strategies inside this simulation are based on the paper [Yet Another
Mastermind Strategy][] by Barteld Kooi.

  [Yet Another Mastermind Strategy]: http://www.philos.rug.nl/~barteld/master.pdf
