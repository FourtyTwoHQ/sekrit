require "test_helper"

class EncoderTest < Minitest::Test

  def setup
    password = 'hello, world!'
    @encoder = Sekrit::Encoder.new(password: password)
    @decoder = Sekrit::Decoder.new(password: password)
  end

  def test_decoding_works_from_encoding
    string = "Peter Paker"
    encoded = @encoder.encode(string: string)
    decoded = @decoder.decode(string: encoded)

    assert_equal string, decoded
  end
end
