require "mml2wav/scale"

module Mml2wav
  class Parser
    def initialize(sounds, sampling_rate, options={})
      pattern = /T\d+|V\d+|L\d+|[A-GR][#+-]?\d*\.?(?:&[A-GR][#+-]?\d*\.?)*|O\d+|[><]|./i
      @sounds = sounds.scan(pattern)
      @sampling_rate = sampling_rate
      @bpm = options[:bpm] || 120
      @velocity = options[:velocity] || 5
      @octave = options[:octave] || 4
      @default_length = options[:default_length] || 4.0
      @octave_reverse = options[:octave_reverse] || false
    end

    def parse
      infos = []
      @sounds.each do |sound|
        base_sec = 60.0 * 4
        length = @default_length
        case sound
        when /\AT(\d+)/i
          @bpm = $1.to_i
          next
        when /\AV(\d+)/i
          @velocity = $1.to_i
          next
        when /\AL(\d+)/i
          @default_length = $1.to_f
          next
        when /\A([A-GR][#+-]?)(\d+)?(\.)?((?:&[A-GR][#+-]?\d*\.?)*)/i
          sound = $1
          length = $2.to_f if $2
          length /= 1.5 if $3
          sec = base_sec / length / @bpm
          if $4
            $4.scan(/&[A-GR][#+-]?(\d+)?(\.)?/i).each do |len, dot|
              if len
                sub_length = len.to_f
              else
                sub_length = @default_length
              end
              sub_length /= 1.5 if dot
              sub_sec = base_sec / sub_length / @bpm
              sec += sub_sec
            end
          end
        when /\AO(\d+)/i
          @octave = $1.to_i
          next
        when "<"
          @octave += @octave_reverse ? -1 : 1
          next
        when ">"
          @octave -= @octave_reverse ? -1 : 1
          next
        end
        amplitude = @velocity.to_f / 10
        frequency = Scale::FREQUENCIES[sound.downcase]
        next unless frequency
        frequency *= (2 ** @octave)
        infos << {
          sound: sound.downcase,
          frequency: frequency,
          sampling_rate: @sampling_rate,
          sec: sec,
          amplitude: amplitude,
        }
      end
      infos
    end
  end
end
