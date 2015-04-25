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
      @sine_waves = {}
      WaveFile::Writer.new(output_path, format) do |writer|
        buffer_format = WaveFile::Format.new(:mono, :float, 8000)
        sounds.split(//).each do |sound|
          frequency = Scale::FREQUENCIES[sound.downcase.to_sym] || 0
          samples = (@sine_waves[sound] ||= sine_wave(frequency))
          buffer = WaveFile::Buffer.new(samples, buffer_format)
          writer.write(buffer)
        end
      end
    end

    desc "version", "Show version"
    def version
      puts(VERSION)
    end

    private
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
