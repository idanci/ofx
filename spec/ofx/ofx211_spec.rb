require "spec_helper"

describe OFX::Parser::OFX211 do
  let(:ofx)    { OFX::Parser::Base.new("spec/fixtures/v211.ofx") }
  let(:parser) { ofx.parser }

  it "should have a version" do
    OFX::Parser::OFX211::VERSION.should == "2.1.1"
  end

  it "should set headers" do
    parser.headers.should == ofx.headers
  end

  it "should set body" do
    parser.body.should == ofx.body
  end

  it "should set accounts" do
    parser.accounts.should be_a_kind_of(Array)
    parser.accounts.first.should be_a_kind_of(OFX::Account)
  end

  it "should set sign_on" do
    parser.sign_on.should be_a_kind_of(OFX::SignOn)
  end

  context "transactions" do
    # Test file contains only three transactions. Let's just check
    # them all.
    context "first" do
      let(:t) { parser.accounts.first.transactions[0] }

      it "should contain the correct values" do
        t.amount.should == -80
        t.fit_id.should == "219378"
        t.memo.should be_empty
        t.posted_at.should == Time.parse("2005-08-24 08:00:00")
        t.name.should == "FrogKick Scuba Gear"
      end
    end

    context "second" do
      let(:t) { parser.accounts.last.transactions[0] }

      it "should contain the correct values" do
        t.amount.should == -23
        t.fit_id.should == "219867"
        t.memo.should be_empty
        t.posted_at.should == Time.parse("2005-08-11 08:00:00")
        t.name.should == "Interest Charge"
      end
    end

    context "third" do
      let(:t) { parser.accounts.last.transactions[1] }

      it "should contain the correct values" do
        t.amount.should == 350
        t.fit_id.should == "219868"
        t.memo.should be_empty
        t.posted_at.should == Time.parse("2005-08-11 08:00:00")
        t.name.should == "Payment - Thank You"
      end
    end
  end
end

