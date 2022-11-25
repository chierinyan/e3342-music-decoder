# ELEC3342 Project

> A music code decoder on FPGA


### Implementation

* ADC data is converted into a square wave.
  The square wave changes only when the data crosses a margin between 0.

* Detection starts working after the second rising edge of the square wave after reset.

* `LD0` turns on when idle or after receiving the second music symbol,
  and turns off after receiving the first symbol.


### Extensions

* Increased Speed of Transmission

    The speed of transmission is doubled to 32 symbols per second,
    with fixed symbols per second.

    (1/32 second for each symbol)


* Robust

    * Allows significant background noise.

    * Allows any musical instrument.


* Expanded code book

    Allows encoding of alphabet, numbers, and common punctuation.

    |     | 0   | 1   | 2   | 3   | 4   | 5   | 6   | 7   |
    | --- | --- | --- | --- | --- | --- | --- | --- | --- |
    | 0   | 0   | 1   | 2   | 3   | 4   | 5   | 6   | n/a |
    | 1   | \n  | \t  | A   | B   | C   | D   | E   | +   |
    | 2   | @   | F   | :   | G   | H   | I   | J   | -   |
    | 3   | #   | K   | L   | ;   | M   | N   | O   | *   |
    | 4   | $   | P   | Q   | R   | [   | S   | T   | /   |
    | 5   | %   | U   | V   | W   | X   | ]   | Y   | ^   |
    | 6   | &   | Z   | !   | ,   | ? |&#x2423;|_   | =   |
    | 7   | n/a | 7   | 8   | 9   | <   | >   | (   | )   |


![fullview.png](https://s1.ax1x.com/2022/11/27/zU9yut.png)

![zoom.png](https://s1.ax1x.com/2022/11/27/zU9rjI.png)

