require "spec_helper"

describe OFX::Parser do
  before do
    @ofx = OFX::Parser::Base.new("spec/fixtures/v102.ofx")
  end

  it "should accept file path" do
    @ofx = OFX::Parser::Base.new("spec/fixtures/v102.ofx")
    @ofx.content.should_not be_nil
  end

  it "should accept file handler" do
    file = open("spec/fixtures/v102.ofx")
    @ofx = OFX::Parser::Base.new(file)
    @ofx.content.should_not be_nil
  end

  it "should accept file content" do
    file = open("spec/fixtures/v102.ofx").read
    @ofx = OFX::Parser::Base.new(file)
    @ofx.content.should_not be_nil
  end

  it "should set content" do
    @ofx.content.should == open("spec/fixtures/v102.ofx").read
  end

  it "should work with UTF8 and Latin1 encodings" do
    @ofx = OFX::Parser::Base.new("spec/fixtures/utf8.ofx")
    @ofx.content.should == open("spec/fixtures/utf8.ofx").read
  end

  it "should set body" do
    @ofx.body.should_not be_nil
  end

  it "should raise exception when trying to parse an unsupported OFX version" do
    lambda {
      OFX::Parser::Base.new("spec/fixtures/invalid_version.ofx")
    }.should raise_error(OFX::UnsupportedFileError)
  end

  it "should raise exception when trying to parse an invalid file" do
    lambda {
      OFX::Parser::Base.new("spec/fixtures/avatar.gif")
    }.should raise_error(OFX::UnsupportedFileError)
  end

  describe "headers" do
    it "should have OFXHEADER" do
      @ofx.headers["OFXHEADER"].should == "100"
    end

    it "should have DATA" do
      @ofx.headers["DATA"].should == "OFXSGML"
    end

    it "should have VERSION" do
      @ofx.headers["VERSION"].should == "102"
    end

    it "should have SECURITY" do
      @ofx.headers.should have_key("SECURITY")
      @ofx.headers["SECURITY"].should be_nil
    end

    it "should have ENCODING" do
      @ofx.headers["ENCODING"].should == "USASCII"
    end

    it "should have CHARSET" do
      @ofx.headers["CHARSET"].should == "1252"
    end

    it "should have COMPRESSION" do
      @ofx.headers.should have_key("COMPRESSION")
      @ofx.headers["COMPRESSION"].should be_nil
    end

    it "should have OLDFILEUID" do
      @ofx.headers.should have_key("OLDFILEUID")
      @ofx.headers["OLDFILEUID"].should be_nil
    end

    it "should have NEWFILEUID" do
      @ofx.headers.should have_key("NEWFILEUID")
      @ofx.headers["NEWFILEUID"].should be_nil
    end

    it "should parse headers with CR and without LF" do
      @ofx = OFX::Parser::Base.new(ofx_with_carriage_return)
      @ofx.headers.size.should be(9)
    end
  end

  def ofx_with_carriage_return
    header = %{OFXHEADER:100\rDATA:OFXSGML\rVERSION:102\rSECURITY:NONE\rENCODING:USASCII\rCHARSET:1252\rCOMPRESSION:NONE\rOLDFILEUID:NONE\rNEWFILEUID:NONE\r}
    body   = open("spec/fixtures/v102.ofx").read.split(/<OFX>/, 2)[1]
    header + "<OFX>" + body
  end
end
