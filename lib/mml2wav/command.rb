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
      @sampling_rate = @options[:sampling_rate] || 8000
      @sounds = arguments.join(" ")
    end

    def run
      format = WaveFile::Format.new(:mono, :pcm_8, @sampling_rate)
      @sine_waves = {}
      WaveFile::Writer.new(@output_path, format) do |writer|
        buffer_format = WaveFile::Format.new(:mono, :float, @sampling_rate)
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

      parser = OptionParser.new("#{$0} 'CDECDEGEDCDED'")
      parser.version = VERSION

      parser.on("--output=FILE", "Specify output file path") do |path|
        options[:output] = path
      end
      parser.on("--sampling_rate=RATE",
                "Specify sampling rate", Integer) do |rate|
        options[:sampling_rate] = rate
      end
      parser.parse!(arguments)

      if arguments.empty?
        puts(parser.help)
        exit(true)
      end

      options
    end

    def sine_wave(frequency, sec=0.1, amplitude=0.5)
      max = @sampling_rate * sec
      if frequency == 0
        return Array.new(max) { 0.0 }
      end
      base_x = 2.0 * Math::PI * frequency / @sampling_rate
      1.upto(max).collect do |n|
        amplitude * Math.sin(base_x * n)
      end
    end
  end
end
