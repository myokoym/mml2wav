# mml2wav [![Gem Version](https://badge.fury.io/rb/mml2wav.svg)](http://badge.fury.io/rb/mml2wav)

MML (Music Macro Language) to WAV audio converter by Ruby.

## Dependencies

* [jstrait/wavefile](https://github.com/jstrait/wavefile)

## Installation

    $ gem install mml2wav

## Usage

    $ mml2wav XXX.mml

Or

    $ echo 'MML TEXT' | mml2wav

## Suppoted MML features

### do re mi...

MML | doremi
--- | ------
c   | do
d   | re
e   | mi
f   | fa
g   | so
a   | la
b   | si

### signs

MML | mean
--- | -----------
r   | rest
t90 | BPM
o4  | octave
<   | up octave
>   | down octave

## License

MIT License. See LICENSE.txt for details.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
