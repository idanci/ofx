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

    it "does not raise errors if transactions list is empty" do
      parser = OFX::Parser::Base.new("spec/fixtures/transactions_empty.ofx").parser

      expect {parser.accounts}.to_not raise_error

      parser.accounts.size.should == 2
      parser.accounts.first.transactions.should be_empty
      parser.accounts.last.transactions.should be_empty

      parser.errors.should be_empty
    end

    it "returns even partial data" do
      parser = OFX::Parser::Base.new("spec/fixtures/accounts_partial.ofx").parser

      expect {parser.accounts}.to_not raise_error

      parser.accounts.size.should == 1
      account = parser.accounts.first
      account.balance.amount.should     == 598.44
      account.bank_id.should            be_empty
      account.id.should                 be_empty
      account.currency.should           == "BRL"
      account.transactions.size.should  == 1
      account.type.should               be_nil
      account.available_balance.should  be_nil

      parser.errors.should be_empty
    end

    it "does not fail if account balance is missing" do
      parser = OFX::Parser::Base.new("spec/fixtures/empty_balance.ofx").parser

      expect {parser.accounts}.to_not raise_error

      parser.accounts.size.should == 1
      parser.accounts.first.balance.should be_nil


      parser.errors.should be_empty
    end
  end
end
