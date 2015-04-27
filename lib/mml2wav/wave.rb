require "wavefile"
require "mml2wav/parser"

module Mml2wav
  class Wave
    class << self
      include WaveFile

      def write(soundses, options={})
        if soundses.is_a?(String)
          n_channels = :mono
          soundses = [soundses]
          size = 1
        elsif soundses.size == 1
          n_channels = :mono
          size = 1
        elsif soundses.size == 2
          n_channels = :stereo
          size = soundses.size
        else
          n_channels = soundses.size
          size = soundses.size
        end
        output_path = options[:output] || "doremi.wav"
        sampling_rate = options[:sampling_rate] || 22050

        format = Format.new(n_channels, :pcm_8, sampling_rate)
        Writer.new(output_path, format) do |writer|
          buffer_format = Format.new(n_channels, :float, sampling_rate)
          parsers = []
          soundses.each do |sounds|
            parsers << Parser.new(sounds, sampling_rate, options)
          end
          waves = Array.new(parsers.size) { [] }
          loop do
            parsers.each_with_index do |parser, i|
              wave = parser.wave!
              waves[i] += wave if wave
            end
            break if waves.all? {|wave| wave.empty? }
            buffer_size = waves.reject {|wave| wave.empty? }.collect(&:size).min
            break unless buffer_size
            samples = []
            buffer_size.times do
              sample = []
              waves.each do |wave|
                if wave.first
                  sample << wave.shift
                else
                  sample << 0.0
                end
              end
              samples << sample
            end
            buffer = Buffer.new(samples, buffer_format)
            writer.write(buffer)
          end
        end
      end
    end
  end
end
