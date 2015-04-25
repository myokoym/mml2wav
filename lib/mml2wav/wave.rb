module Mml2wav
  class Wave
    class << self
      def write(sounds, options={})
        output_path = options[:output] || "doremi.wav"
        sampling_rate = options[:sampling_rate] || 8000

        format = WaveFile::Format.new(:mono, :pcm_8, sampling_rate)
        @sine_waves = {}
        WaveFile::Writer.new(output_path, format) do |writer|
          buffer_format = WaveFile::Format.new(:mono, :float, sampling_rate)
          sounds.split(//).each do |sound|
            frequency = Scale::FREQUENCIES[sound.downcase.to_sym] || 0
            @sine_waves[sound] ||= sine_wave(frequency, sampling_rate)
            samples = @sine_waves[sound]
            buffer = WaveFile::Buffer.new(samples, buffer_format)
            writer.write(buffer)
          end
        end
      end

      private
      def sine_wave(frequency, sampling_rate, sec=0.1, amplitude=0.5)
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
