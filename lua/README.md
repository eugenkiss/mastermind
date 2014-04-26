Usage
-----

To learn how to write a bot have a look at `strategies/dummy.lua` or at the
other bots. To test a bot you need to run `main.lua` like this:

        $ lua main.lua -f strategies/dummy.lua

You can also change the values of some parameters like the cpu slowness factor
(c, must be between 0-infinity), the length of the sequence (l, must be between
1-8), the speed of the robot (r, in mm/second), the time limit (t, in
seconds) and the number of simulations (s). The more simulations you test the
more precise the values will be but the longer it takes to compute the values,
of course. The cpu slowness factor is multiplied with the elapsed time for each
of the bot's computation of the next sequence. So it can be used to simulate
a slower cpu. The following command uses the standard values:

        $ lua main.lua -f strategies/dummy.lua -c 1 -t 360 -r 920 -l 4 -s 3

For quicker tests [Luajit][] is recommended. You need [Luasocket][] installed
on your system! For convenient installation use [Luarocks][].

  [Luajit]: http://luajit.org/
  [Luasocket]: http://w3.impa.br/~diego/software/luasocket/
  [Luarocks]: http://luarocks.org/


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

    $ luajit main.lua -f strategies/simple.lua -t 180 -r 920 -l 3 -s 1000 -c 5

    Testing 'strategies/simple.lua'
    ===============================

    Time Limit:   180 [s]
    Robot Speed:  920 [mm/s]
    Code Length:  3
    CPU Slowness: 5
    Simulations:  1000

    [..........]
     ^^^^^^^^^^

    Results
    -------

    Successes: 11.91300
    Expected:  5.71972 [Guesses/Success]

    Driving Time:  99.92 [%]
    Thinking Time: 0.08 [%]

    |   1   |   2   |   3   |   4   |   5   |   6   |   7   |  >=8  | [Round]
    |===============================================================|
    | 00.60 | 02.32 | 06.87 | 10.96 | 17.15 | 24.47 | 30.30 | 07.32 | [%]

The output is self-explanatory. Note that the cpu speed is simulated as 5x
slower. Let's just for the sake of it reduce the speed of the bot. What do you
expect will happen to the output values?

    $ luajit main.lua -f strategies/simple.lua -t 180 -r 460 -l 3 -s 1000 -c 5

    Testing 'strategies/simple.lua'
    ===============================

    Time Limit:   180 [s]
    Robot Speed:  460 [mm/s]
    Code Length:  3
    CPU Slowness: 5
    Simulations:  1000

    [..........]
     ^^^^^^^^^^

    Results
    -------

    Successes: 5.64400
    Expected:  5.81201 [Guesses/Success]

    Driving Time:  99.97 [%]
    Thinking Time: 0.03 [%]

    |   1   |   2   |   3   |   4   |   5   |   6   |   7   |  >=8  | [Round]
    |===============================================================|
    | 00.44 | 01.93 | 06.77 | 11.78 | 16.53 | 21.88 | 29.93 | 10.74 | [%]

Right! Since the bot moves slower less sequences can be entered in the given
amount of time thus less possible correct guesses and thus a lower score. But
that in itself is not very interesting. The substantial part is to compare
different strategies with the same input values.