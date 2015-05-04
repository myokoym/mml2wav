require "mml2wav/parser"

class TestParser < Test::Unit::TestCase
  def test_a_scale
    parser = Mml2wav::Parser.new("c", 8000)
    assert_equal([
                   {
                     sound: "c",
                     frequency: 523.252,
                     sampling_rate: 8000,
                     sec: 0.5,
                     amplitude: 0.5,
                   },
                 ],
                 parser.parse)
  end

  def test_length
    parser = Mml2wav::Parser.new("c8", 8000)
    assert_equal([
                   {
                     sound: "c",
                     frequency: 523.252,
                     sampling_rate: 8000,
                     sec: 0.25,
                     amplitude: 0.5,
                   },
                 ],
                 parser.parse)
  end

  def test_dot
    parser = Mml2wav::Parser.new("c.", 8000)
    assert_equal([
                   {
                     sound: "c",
                     frequency: 523.252,
                     sampling_rate: 8000,
                     sec: 0.75,
                     amplitude: 0.5,
                   },
                 ],
                 parser.parse)
  end

  def test_length_with_dot
    parser = Mml2wav::Parser.new("c8.", 8000)
    assert_equal([
                   {
                     sound: "c",
                     frequency: 523.252,
                     sampling_rate: 8000,
                     sec: 0.375,
                     amplitude: 0.5,
                   },
                 ],
                 parser.parse)
  end

  def test_a_tie
    parser = Mml2wav::Parser.new("c&c", 8000, bpm: 60)
    assert_equal([
                   {
                     sound: "c",
                     frequency: 523.252,
                     sampling_rate: 8000,
                     sec: 2.0,
                     amplitude: 0.5,
                   },
                 ],
                 parser.parse)
  end

  def test_a_tie_with_length
    parser = Mml2wav::Parser.new("c&c16", 8000, bpm: 60)
    assert_equal([
                   {
                     sound: "c",
                     frequency: 523.252,
                     sampling_rate: 8000,
                     sec: 1.25,
                     amplitude: 0.5,
                   },
                 ],
                 parser.parse)
  end

  def test_a_tie_with_dot
    parser = Mml2wav::Parser.new("c&c.", 8000, bpm: 60)
    assert_equal([
                   {
                     sound: "c",
                     frequency: 523.252,
                     sampling_rate: 8000,
                     sec: 2.5,
                     amplitude: 0.5,
                   },
                 ],
                 parser.parse)
  end

  def test_a_tie_with_length_with_dot
    parser = Mml2wav::Parser.new("c&c2.", 8000, bpm: 60)
    assert_equal([
                   {
                     sound: "c",
                     frequency: 523.252,
                     sampling_rate: 8000,
                     sec: 4.0,
                     amplitude: 0.5,
                   },
                 ],
                 parser.parse)
  end

  def test_ties
    parser = Mml2wav::Parser.new("c&c&c", 8000, bpm: 60)
    assert_equal([
                   {
                     sound: "c",
                     frequency: 523.252,
                     sampling_rate: 8000,
                     sec: 3.0,
                     amplitude: 0.5,
                   },
                 ],
                 parser.parse)
  end
end
