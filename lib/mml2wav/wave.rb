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
          infoses = []
          soundses.each do |sounds|
            infoses << Parser.new(sounds, sampling_rate, options).parse
          end
          waves = Array.new(soundses.size) { [] }
          0.upto(infoses.collect {|info| info.size }.max) do |infos_index|
            infoses.each_with_index do |infos, infoses_index|
              next unless infos[infos_index]
              wave = sine_wave(infos[infos_index][:frequency],
                               infos[infos_index][:sampling_rate],
                               infos[infos_index][:sec],
                               infos[infos_index][:amplitude])
              waves[infoses_index] += wave
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
