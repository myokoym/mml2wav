require "optparse"
require "mml2wav/version"
require "mml2wav/wave"

module Mml2wav
  class Command
    def self.run(arguments)
      new(arguments).run
    end

    def initialize(arguments)
      @options = parse_options(arguments)
      channel_delimiter = @options[:channel_delimiter] || ","
      channels = ARGF.readlines.join.split(/#{channel_delimiter}/)
      @sounds = channels.reject {|channel| channel.empty? }
    end

    def run
      Wave.write(@sounds, @options)
    end

    private
    def parse_options(arguments)
      options = {}

      parser = OptionParser.new("#{$0} INPUT_FILE")
      parser.version = VERSION

      parser.on("--output=FILE", "Specify output file path") do |path|
        options[:output] = path
      end
      parser.on("--sampling_rate=RATE",
                "Specify sampling rate", Integer) do |rate|
        options[:sampling_rate] = rate
      end
      parser.on("--bpm=BPM",
                "Specify BPM (beats per minute)", Integer) do |bpm|
        options[:bpm] = bpm
      end
      parser.on("--octave_reverse",
                "Reverse octave sign (><) effects") do |boolean|
        options[:octave_reverse] = boolean
      end
      parser.on("--channel_delimiter=DELIMITER",
                "Specify channel delimiter") do |delimiter|
        options[:channel_delimiter] = delimiter
      end
      parser.parse!(arguments)

      unless File.pipe?('/dev/stdin') || IO.select([ARGF], nil, nil, 0)
        puts(parser.help)
        exit(true)
      end

      options
    end
  end
end
