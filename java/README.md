Usage
-----

To learn how to write a bot have a look at
`src/strategy/implementations/Dummy.java` or at the other bots. To test a bot
you need to run `src/simulation/Main.java` (with eclipse).

`src/simulation/Main.java` is commented and you simply need to alter the
constants to change the parameters of the simulation.

This project can be imported to eclipse.


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

Well now, let's compare two outputs:

    Testing 'Simple'
    ================

    Time Limit:  180 [s]
    Robot Speed: 400.0 [mm/s]
    Code Length: 3
    CPU Divisor: 100.0
    Simulations: 100

    [..........]
     ^^^^^^^^^^

    Results
    -------

    Successes: 3.25000
    Expected:  4.43692 [Guesses/Success]

    Driving Time:  99.97 [%]
    Thinking Time: 0.03 [%]

    |   1   |   2   |   3   |   4   |   5   |   6   |   7   |  >=8  | [Round]
    |===============================================================|
    | 00.31 | 01.85 | 12.31 | 38.46 | 34.46 | 11.69 | 00.92 | 00.00 | [%]

The output is self-explanatory. Note that the cpu speed is simulated as 100x
slower. Let's just for the sake of it reduce the speed of the bot. What do you
expect will happen to the output values?

    Testing 'Simple'
    ================

    Time Limit:  180 [s]
    Robot Speed: 200.0 [mm/s]
    Code Length: 3
    CPU Divisor: 100.0
    Simulations: 100

    [..........]
     ^^^^^^^^^^

    Results
    -------

    Successes: 1.48000
    Expected:  4.11486 [Guesses/Success]

    Driving Time:  99.97 [%]
    Thinking Time: 0.03 [%]

    |   1   |   2   |   3   |   4   |   5   |   6   |   7   |  >=8  | [Round]
    |===============================================================|
    | 01.35 | 06.76 | 14.86 | 43.24 | 24.32 | 08.78 | 00.68 | 00.00 | [%]

Right! Since the bot moves slower less sequences can be entered in the given
amount of time thus less possible correct guesses and thus less successes. But
that in itself is not very interesting. The substantial part is to compare
different strategies with the same input values.