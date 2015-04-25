require "wavefile"
require "optparse"
require "mml2wav/scale"
require "mml2wav/version"

module Mml2wav
  class Command
    def self.run(arguments)
      new(arguments).run
    end

    def initialize(arguments)
      @options = parse_options(arguments)
      @output_path = @options[:output] || "doremi.wav"
      @sounds = arguments.join(" ")
    end

    def run
      format = WaveFile::Format.new(:mono, :pcm_8, 8000)
      @sine_waves = {}
      WaveFile::Writer.new(@output_path, format) do |writer|
        buffer_format = WaveFile::Format.new(:mono, :float, 8000)
        @sounds.split(//).each do |sound|
          frequency = Scale::FREQUENCIES[sound.downcase.to_sym] || 0
          samples = (@sine_waves[sound] ||= sine_wave(frequency))
          buffer = WaveFile::Buffer.new(samples, buffer_format)
          writer.write(buffer)
        end
      end
    end

    private
    def parse_options(arguments)
      options = {}

      parser = OptionParser.new("#{$0} \'CDECDEGEDCDED\'")
      parser.version = VERSION

      parser.on("--output=FILE", "Specify output file path") do |path|
        options[:output] = path
      end
      parser.parse!(arguments)

      if arguments.empty?
        puts(parser.help)
        exit(true)
      end

      options
    end

    def sine_wave(frequency, rate=8000, sec=0.1, velocity=0.5)
      max = rate * sec
      if frequency == 0
        return Array.new(max) { 0.0 }
      end
      0.upto(max).collect do |n|
        Math.sin(2.0 * Math::PI * n / rate * frequency) * velocity
      end
    end
  end
end
