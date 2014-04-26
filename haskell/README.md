Usage
-----

First, you must build/compile the project. The easiest way to do this is:

    $ ghc --make Main -o mastermind-sim

An alternative is to use cabal:

    $ cabal configure
    $ cabal build
    $ cabal install

`cabal install` is optional. If you don't want to install this project you can
access the executable like that:

    $ dist/build/mastermind-sim/mastermind-sim

In any case you'll have an executable `mastermind-sim`.

To learn how to write a bot have a look at `Strategies/Dummy.hs` or at the
other bots. To test a bot you need to run `mastermind-sim` like this:

    $ mastermind-sim -a dummy

You can also change the values of some parameters like the cpu slowness factor
(c, must be between 0-infinity), the length of the sequence (l, must be between
1-infinity), the speed of the robot (r, in mm/second), the time limit (t, in
seconds), the number of simulations (x) and the seed (s). The more simulations
you test the more precise the values will be but the longer it takes to compute
the result. The cpu slowness factor is multiplied with the elapsed time for
each of the bot's computation of the next sequence. So it can be used to
simulate a slower cpu. The seed can be used to have reproducable results. If no
seed is given the seed is provided by the system. To show help for the command
line arguments simply attach the help flag like so

    $ mastermind-sim -h


### Interpretation Of The Output

As mentionend in the introduction a good bot should be fast. That is, it should
not take too much time to compute the next sequence to test simply because of
the time limit. An algorithm with a worse guess rate (i.e. one that needs a lot
of tries until it determines the secret sequence) but a fast decision rate
(i.e. it needs hardly any time to compute the next guess to take) and a clever
picking of the shortest route may get a higher score than an algorithm with an
optimal guess rate but a slow decision rate. This is why it is important to
understand what the values of the output mean in order to be able to correctly
evaluate the fitness of a bot.

A bot moves with a constant speed. So it takes time to get from one button to
the other. Additionally, after each entered sequence the bot needs time to
compute the next one. This delay is measured in *real* elapsed time so it
depends on which machine you run the code, which interpreter/compiler you use,
which programs run in the background etc. In general one can say that if you
use the same machine and set the number of simulations high enough a useful
output will be produced. Again, this output can only be compared with
confidence to output that has been determined on the same machine with the same
input values (apart from the used strategy of course). However, you can
simulate a slower cpu. So if you measured, by e.g. benchmarking a program on
the NXT and your PC, how much slower the NXT is compared to your PC you can use
this value to set the "slowness factor".

Well now, let's compare two outputs from two different strategies:

    $ mastermind-sim -a simple -s 1 -t 180 -r 920 -l 3 -x 100 -c 5

    Testing simple
    ==============

    Time Limit:   180 [s]
    Robot Speed:  920.0 [mm/s]
    Code Length:  3
    CPU Slowness: 5.0
    Simulations:  100

    [..........]
     ^^^^^^^^^^

    Results
    -------

    Successes: 12.54000
    Expected:  6.61722 [Guesses/Success]

    Driving Time:   99.84 [%]
    Thinking Time:   0.16 [%]

    |   1   |   2   |   3   |   4   |   5   |   6   |   7   |  >=8  | [Round]
    |===============================================================|
    | 00.00 | 00.08 | 01.83 | 08.77 | 13.96 | 18.42 | 21.61 | 35.33 | [%]

The output is self-explanatory. Note that the cpu speed is simulated as 5x
slower. Let's just for the sake of it reduce the speed of the bot. What do you
expect will happen to the output values?

    $ mastermind-sim -a simple -s 1 -t 180 -r 460 -l 3 -x 100 -c 5

    Testing simple
    ==============

    Time Limit:   180 [s]
    Robot Speed:  460.0 [mm/s]
    Code Length:  3
    CPU Slowness: 5.0
    Simulations:  100

    [..........]
     ^^^^^^^^^^

    Results
    -------

    Successes: 6.22000
    Expected:  6.40836 [Guesses/Success]

    Driving Time:   99.92 [%]
    Thinking Time:   0.08 [%]

    |   1   |   2   |   3   |   4   |   5   |   6   |   7   |  >=8  | [Round]
    |===============================================================|
    | 00.00 | 00.16 | 02.73 | 11.09 | 16.08 | 18.65 | 20.58 | 30.71 | [%]

Right! Since the bot moves slower less sequences can be entered in the given
amount of time thus less possible correct guesses and thus a lower score. But
that in itself is not very interesting. The substantial part is to compare
different strategies with the same input values.