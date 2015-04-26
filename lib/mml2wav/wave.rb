require "wavefile"
require "mml2wav/scale"

module Mml2wav
  class Wave
    class << self
      include WaveFile

      def write(sounds, options={})
        output_path = options[:output] || "doremi.wav"
        sampling_rate = options[:sampling_rate] || 22050
        bpm = options[:bpm] || 600
        velocity = 5
        octave = 4

        format = Format.new(:mono, :pcm_8, sampling_rate)
        Writer.new(output_path, format) do |writer|
          buffer_format = Format.new(:mono, :float, sampling_rate)
          sounds.scan(/T\d+|V\d+|[A-G][#+]?\d*|O\d+|[><]|./i).each do |sound|
            base_sec = 60.0
            note = 4
            case sound
            when /\AT(\d+)/i
              bpm = $1.to_i
            when /\AV(\d+)/i
              velocity = $1.to_i
            when /\A([A-G][#+]?)(\d+)/i
              note = $2.to_i
              sound = $1
            when /\AO(\d+)/i
              octave = $1.to_i
            when "<"
              octave += 1
            when ">"
              octave -= 1
            end
            sec = base_sec / note / bpm
            amplitude = velocity.to_f / 10
            frequency = Scale::FREQUENCIES[sound.downcase]
            next unless frequency
            frequency *= (2 ** octave)
            samples = sine_wave(frequency, sampling_rate, sec, amplitude)
            buffer = Buffer.new(samples, buffer_format)
            writer.write(buffer)
          end
        end
      end

      private
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
