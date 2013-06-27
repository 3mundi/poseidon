require 'spec_helper'

describe Message do
  describe "when constructing a new message" do
    it 'raises an ArgumentError on unknown options' do
      expect { Message.new(:cow => "dog") }.to raise_error(ArgumentError)
    end

    it 'handles options correctly' do
      m = Message.new(:value => "value",
                      :key => "key",
                      :attributes => 1,
                      :topic => "topic")

      expect(m.value).to eq("value")
      expect(m.key).to eq("key")
      expect(m.compressed?).to eq(true)
      expect(m.topic).to eq("topic")
    end
  end

  describe "checksum" do
    context "is incorrect" do
      before(:each) do
        m = Message.new(:value => "value",
                        :key => "key",
                        :topic => "topic")

        req_buf = Protocol::RequestBuffer.new
        m.write(req_buf)

        @s = req_buf.to_s
        @s[-1] = "q" # break checksum
      end

      it "knows it" do
        expect { Message.read(Protocol::ResponseBuffer.new(@s)) }.to raise_error(Errors::ChecksumError)
      end
    end

    context 'is correct' do
      before(:each) do
        m = Message.new(:value => "value",
                        :key => "key",
                        :topic => "topic")

        req_buf = Protocol::RequestBuffer.new
        m.write(req_buf)

        @s = req_buf.to_s
      end

      it "raises no error" do
        expect { Message.read(Protocol::ResponseBuffer.new(@s)) }.to_not raise_error
      end
    end

    it 'knows when the checksum failed' do
    end
  end

  context "invalid utf8 string for value" do
    it "builds the payload without error" do
      expect {
        s = "asdf\xffasdf"
        m = Message.new(:value => s,
                        :key => "key",
                        :topic => "topic")

        req_buf = Protocol::RequestBuffer.new
        m.write(req_buf)
      }.to_not raise_error
    end
  end

  it "decompresses a compressed value"

  it "raises an error if you try to decompress an uncompressed value"

  describe "#write" do
    it 'writes a MessageWithOffsetStruct to the request buffer' do
    end
  end
end
