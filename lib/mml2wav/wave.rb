require "wavefile"
require "mml2wav/scale"

module Mml2wav
  class Wave
    class << self
      include WaveFile

      def write(sounds, options={})
        output_path = options[:output] || "doremi.wav"
        sampling_rate = options[:sampling_rate] || 8000
        bpm = options[:bpm] || 600

        format = Format.new(:mono, :pcm_8, sampling_rate)
        @sine_waves = {}
        Writer.new(output_path, format) do |writer|
          buffer_format = Format.new(:mono, :float, sampling_rate)
          sounds.scan(/T\d+|./i).each do |sound|
            case sound
            when /\AT(\d+)/i
              bpm = $1.to_i
            end
            frequency = Scale::FREQUENCIES[sound.downcase]
            next unless frequency
            @sine_waves[sound] ||= sine_wave(frequency, sampling_rate, bpm)
            samples = @sine_waves[sound]
            buffer = Buffer.new(samples, buffer_format)
            writer.write(buffer)
          end
        end
      end

      private
      def sine_wave(frequency, sampling_rate, bpm=600, amplitude=0.5)
        sec = 60.0 / bpm
        max = sampling_rate * sec
        if frequency == 0
          return Array.new(max) { 0.0 }
        end
        base_x = 2.0 * Math::PI * frequency / sampling_rate
        1.upto(max).collect do |n|
          amplitude * Math.sin(base_x * n)
        end
      end
    end
  end
end
