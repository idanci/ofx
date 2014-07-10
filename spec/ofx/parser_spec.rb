require "spec_helper"

describe OFX::Parser::Base do
  let(:ofx)    { OFX::Parser::Base.new("spec/fixtures/v102.ofx") }
  let(:parser) { ofx.parser }

  describe "initialize" do
    it "does not raise error if valid file given" do
      expect{ OFX::Parser::Base.new("spec/fixtures/v102.ofx") }.not_to raise_error
      expect{ OFX::Parser::Base.new("spec/fixtures/v211.ofx") }.not_to raise_error
    end

    it "raises error if file has not valid format" do
      expect do
        OFX::Parser::Base.new("spec/fixtures/missing_headers.ofx")
      end.to raise_error(OFX::UnsupportedFileError)
    end
  end
end
