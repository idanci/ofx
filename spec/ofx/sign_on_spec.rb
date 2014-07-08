require "spec_helper"

describe OFX::SignOn do
  let(:ofx)     { OFX::Parser::Base.new("spec/fixtures/creditcard.ofx") }
  let(:parser)  { ofx.parser }
  let(:sign_on) { parser.sign_on }
  let(:hash)    { sign_on.to_hash }

  describe "sign_on" do
    it "should return language" do
      sign_on.language.should == "ENG"
      hash[:language].should == "ENG"
    end

    it "should return Financial Institution ID" do
      sign_on.fi_id.should == "24909"
      hash[:fi_id].should == "24909"
    end

    it "should return Financial Institution Name" do
      sign_on.fi_name.should == "Citigroup"
      hash[:fi_name].should == "Citigroup"
    end

    context "#to_hash" do
      it "should return Hash" do
        hash.should be_a_kind_of(Hash)
      end
    end
  end
end
