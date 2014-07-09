require "spec_helper"

describe OFX::Accounts do
  let(:ofx)      { OFX::Parser::Base.new("spec/fixtures/v211.ofx") }
  let(:accounts) { ofx.parser.accounts }
  let(:hash)     { accounts.to_hash }

  describe "accounts" do
    it "should return multiple accounts" do
      accounts.size.should == 2
    end

    context "#to_hash" do
      it "should return array of Hashes" do
        hash.should be_a_kind_of(Array)
        hash.first.should be_a_kind_of(Hash)
      end
    end
  end
end
