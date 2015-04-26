require "wavefile"
require "mml2wav/scale"

module Mml2wav
  class Wave
    class << self
      include WaveFile

      def write(soundses, options={})
        if soundses.is_a?(String)
          channel_type = :mono
          soundses = [soundses]
          size = 1
        elsif soundses.size == 1
          channel_type = :mono
          size = 1
        else
          channel_type = :stereo
          size = soundses.size
        end
        output_path = options[:output] || "doremi.wav"
        sampling_rate = options[:sampling_rate] || 22050
        bpm = options[:bpm] || 120
        velocity = 5
        octave = 4
        default_length = 4.0

        format = Format.new(channel_type, :pcm_8, sampling_rate)
        Writer.new(output_path, format) do |writer|
          buffer_format = Format.new(channel_type, :float, sampling_rate)
          parse(soundses.first, bpm, velocity, octave, default_length, sampling_rate) do |samples|
            buffer = Buffer.new(samples, buffer_format)
            writer.write(buffer)
          end
        end
      end

      private
      def parse(sounds, bpm, velocity, octave, default_length, sampling_rate)
          sounds.scan(/T\d+|V\d+|L\d+|[A-G][#+-]?\d*\.?|O\d+|[><]|./i).each do |sound|
            base_sec = 60.0 * 4
            length = default_length
            case sound
            when /\AT(\d+)/i
              bpm = $1.to_i
            when /\AV(\d+)/i
              velocity = $1.to_i
            when /\AL(\d+)/i
              default_length = $1.to_f
            when /\A([A-G][#+-]?)(\d+)(\.)?/i
              length = $2.to_f
              sound = $1
              length = default_length / 1.5 if $3
            when /\AO(\d+)/i
              octave = $1.to_i
            when "<"
              octave += 1
            when ">"
              octave -= 1
            end
            sec = base_sec / length / bpm
            amplitude = velocity.to_f / 10
            frequency = Scale::FREQUENCIES[sound.downcase]
            next unless frequency
            frequency *= (2 ** octave)
            yield sine_wave(frequency, sampling_rate, sec, amplitude)
          end
      end

      def sine_wave(frequency, sampling_rate, sec, amplitude=0.5)
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
