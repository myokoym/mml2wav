require "mml2wav/scale"

module Mml2wav
  class Parser
    def initialize(sounds, sampling_rate, options={})
      pattern = /T\d+|V\d+|L\d+|[A-G][#+-]?\d*\.?|O\d+|[><]|./i
      @sounds = sounds.scan(pattern)
      @sampling_rate = sampling_rate
      @bpm = options[:bpm] || 120
      @velocity = options[:velocity] || 5
      @octave = options[:octave] || 4
      @default_length = options[:default_length] || 4.0
      @cursor = 0
    end

    def wave!
      @cursor.upto(@sounds.size - 1) do |i|
        sound = @sounds[i]
        base_sec = 60.0 * 4
        length = @default_length
        case sound
        when /\AT(\d+)/i
          @bpm = $1.to_i
        when /\AV(\d+)/i
          @velocity = $1.to_i
        when /\AL(\d+)/i
          @default_length = $1.to_f
        when /\A([A-G][#+-]?)(\d+)(\.)?/i
          length = $2.to_f
          sound = $1
          length = @default_length / 1.5 if $3
        when /\AO(\d+)/i
          @octave = $1.to_i
        when "<"
          @octave += 1
        when ">"
          @octave -= 1
        end
        sec = base_sec / length / @bpm
        amplitude = @velocity.to_f / 10
        frequency = Scale::FREQUENCIES[sound.downcase]
        next unless frequency
        frequency *= (2 ** @octave)
        wave = sine_wave(frequency, @sampling_rate, sec, amplitude)
        @cursor = i + 1
        return wave
      end
      nil
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
