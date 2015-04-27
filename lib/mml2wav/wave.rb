require "wavefile"
require "mml2wav/parser"

module Mml2wav
  class Wave
    class << self
      include WaveFile

      def write(sounds, options={})
        output_path = options[:output] || "doremi.wav"
        sampling_rate = options[:sampling_rate] || 22050

        format = Format.new(:mono, :pcm_8, sampling_rate)
        Writer.new(output_path, format) do |writer|
          buffer_format = Format.new(:mono, :float, sampling_rate)
          parser = Parser.new(sounds, sampling_rate, options)
          while samples = parser.wave!
            buffer = Buffer.new(samples, buffer_format)
            writer.write(buffer)
          end
        end
      end
    end
  end
end
