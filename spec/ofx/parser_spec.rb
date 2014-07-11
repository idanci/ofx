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

    it "does not raise errors if parsing gone bad" do
      parser = OFX::Parser::Base.new("spec/fixtures/date_missing.ofx").parser

      expect {parser.accounts}.to_not raise_error

      parser.accounts.size.should == 1
      # Total 3 transactions, 2 of them raised error during the parsing
      parser.accounts.first.transactions.size.should == 1
      parser.errors.size.should                      == 2

      parser.errors.first.should be_a_kind_of(OFX::ParseError)
    end
  end
end
