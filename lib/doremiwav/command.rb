require "wavefile"
require "thor"
require "doremiwav/scale"
require "doremiwav/version"

module Doremiwav
  class Command < Thor
    desc "generate SOUND...", "Generate wav from string"
    option :output
    def generate(sounds)
      output_path = options[:output] || "doremi.wav"
      format = WaveFile::Format.new(:mono, :pcm_8, 8000)
      WaveFile::Writer.new(output_path, format) do |writer|
        buffer_format = WaveFile::Format.new(:mono, :float, 8000)
        sounds.split(//).each do |sound|
          samples = SCALES[sound.downcase.to_sym] * 10
          buffer = WaveFile::Buffer.new(samples, buffer_format)
          writer.write(buffer)
        end
      end
    end

    def version
      puts(VERSION)
    end
  end
end
