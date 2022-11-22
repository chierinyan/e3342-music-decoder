#!/usr/bin/env python3

import numpy as np
from scipy.io import wavfile

from gen_lut import CODE_TABLE

FREQ = 32
SAMPLE_RATE = 96000
NOTES = np.array([523.25, 659.25, 783.99, 987.77, 1174.66, 1396.91, 1760.00, 2093.00])

# for txt only
AMPLITUDE = 2 ** 11 - 1
NOISE_MU, NOISE_SIGMA = 0, 0.05 # gaussian noice

PLAIN_TEXT = '[ELEC-3342]@<HKU> IS THE BEST ^_^\tBUT I **HATE** VHDL :(\n'
WAV = True
TXT = True


# TODO
def gen_wave(phases, instrument='sin'):
    if instrument == 'sin':
        return np.sin(phases)
    else:
        raise NotImplementedError(f'{instrument} is not implemented')


t = np.linspace(0, 1/FREQ, SAMPLE_RATE//FREQ)
angular_frequencies = NOTES * 2 * np.pi
phases = np.dot(angular_frequencies[:, None], t[None, :])
waves = gen_wave(phases)

code = ''.join([CODE_TABLE[i] for i in PLAIN_TEXT])
code = '0707' + code + '7070'
code = np.frombuffer(code.encode('ASCII'), np.int8) - 48 # str to nparray
y = waves[code].flatten()

if WAV:
    wavfile.write(f'wave.wav', SAMPLE_RATE, np.tile(y, 10))

if TXT:
    y += 1 + np.random.normal(NOISE_MU, NOISE_SIGMA, y.shape)
    y = np.clip(y, 0, 2)
    y *= AMPLITUDE
    binstr = np.vectorize(lambda i: format(i, '012b'))(y.astype(np.uint16))
    np.savetxt('info_wave.txt', binstr, delimiter='\n', fmt='%s')
    print('SAMPLE_LEN:', y.size)

