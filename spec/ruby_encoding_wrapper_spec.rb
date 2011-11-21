require 'spec_helper'

def fake_error(message)
  FakeWeb.register_uri(:post, 'http://manage.encoding.com/', :body => "<?xml version=\"1.0\"?><response><errors><error>#{message}</error></errors></response>")
end

describe RubyEncodingWrapper do

  before do
    FakeWeb.clean_registry
    @sut = RubyEncodingWrapper.new
  end

  describe "#request_encoding" do

    describe "invalid user id or key" do
      before do
        fake_error(ErrorMessage::AUTHENTICATION)
        @result = @sut.request_encoding {|query|}
      end
      it 'should be nil' do
        @result.should be_nil
      end
      it 'should have "Wrong user id or key" as an error' do
        @sut.last_error.should =~ /#{ErrorMessage::AUTHENTICATION}/
      end
    end

    describe "the server returns a 404 error code" do
      before do
        FakeWeb.register_uri(:post, "http://manage.encoding.com/", :body => '', :status => ['404', 'Not Found'])
        @result = @sut.request_encoding { |query| }
      end

      it 'should return nil' do
        @result.should be_nil
      end

      it 'should have "Not Found" as an error' do
        @sut.last_error.should == 'Not Found'
      end

    end

    describe "the server returns a 500 error code" do
      before do
        FakeWeb.register_uri(:post, "http://manage.encoding.com/", :body => '', :status => ['500', 'Server Error'])
        @result = @sut.request_encoding { |query| }
      end

      it 'should return nil' do
        @result.should be_nil
      end

      it 'should have "Server Error" as an error' do
        @sut.last_error.should == 'Server Error'
      end

    end

    describe "no specified format(s)" do
      before do
        fake_error(ErrorMessage::NO_FORMATS)
        @result = @sut.request_encoding {|query|}
      end

      it "should have 'No formats specified' as an error" do
        @sut.last_error.should =~ /#{ErrorMessage::NO_FORMATS}/
      end
    end

    describe "no source specified" do
      before do
        fake_error(ErrorMessage::NO_SOURCE)
        @result = @sut.request_encoding do |query|
          query.format do |f|
            f.output('iphone')
          end
        end
      end

      it 'should have "Source file is not indicated" as an error' do
        @sut.last_error.should =~ /#{ErrorMessage::NO_SOURCE}/
      end

    end

    describe "valid encoding request" do
      before do
        @media_id = 1234
        FakeWeb.register_uri(:post, 'http://manage.encoding.com/', :body => "<?xml version=\"1.0\"?><response><message>Added</message><MediaID>#{@media_id}</MediaID></response>")
        @result = @sut.request_encoding { |query| }
      end
      it 'should return a MediaID' do
        @result.should == @media_id
      end
    end


  end

  describe "#request_status" do
    describe "invalid user id or key" do
      before do
        fake_error("Wrong user id or key!")
        @result = @sut.request_status(1234)
      end
      it 'should be nil' do
        @result.should be_nil
      end
      it 'should have "Wrong user id or key" as an error' do
        @sut.last_error.should =~ /Wrong user id or key/
      end
    end

    describe "the server returns a 404 error code" do
      before do
        FakeWeb.register_uri(:post, "http://manage.encoding.com/", :body => '', :status => ['404', 'Not Found'])
        @result = @sut.request_status(1234) 
      end

      it 'should return nil' do
        @result.should be_nil
      end

      it 'should have "Not Found" as an error' do
        @sut.last_error.should == 'Not Found'
      end

    end

    describe "the server returns a 500 error code" do
      before do
        FakeWeb.register_uri(:post, "http://manage.encoding.com/", :body => '', :status => ['500', 'Server Error'])
        @result = @sut.request_status(1234) 
      end

      it 'should return nil' do
        @result.should be_nil
      end

      it 'should have "Server Error" as an error' do
        @sut.last_error.should == 'Server Error'
      end

    end

    describe "valid status request" do
      before do
        @media_id = 1234
        @progress = 10
        FakeWeb.register_uri(:post, 'http://manage.encoding.com/', :body => "<?xml version=\"1.0\"?><response><id>#{@media_id}</id><status>#{EncodingStatusType::PROCESSING}</status><progress>#{@progress}</progress></response>")
        @result = @sut.request_status(@media_id)
      end

      it 'should return "Processing"' do
        @result[ :message ].should =~ /#{EncodingStatusType::PROCESSING}/
      end

      it 'should return 10% progress' do
        @result[ :progress ].should == @progress
      end
      
    end

    describe "waiting for encoder" do
      before do
        @media_id = 1234
        @progress = 100
        FakeWeb.register_uri(:post, 'http://manage.encoding.com/', :body => "<?xml version=\"1.0\"?><response><id>#{@media_id}</id><status>#{EncodingStatusType::WAITING}</status><progress>#{@progress}</progress></response>")
        @result = @sut.request_status(@media_id)
      end
      it 'should have 0% progress' do
        @result[ :progress ].should be 0
      end
    end

  end

  describe "#cancel_media" do

    describe "invalid user id or key" do
      before do
        fake_error(ErrorMessage::AUTHENTICATION)
        @result = @sut.cancel_media(1234)
      end
      it 'should be nil' do
        @result.should be_nil
      end
      it 'should have "Wrong user id or key" as an error' do
        @sut.last_error.should =~ /#{ErrorMessage::AUTHENTICATION}/
      end
    end

    describe "the server returns a 404 error code" do
      before do
        FakeWeb.register_uri(:post, "http://manage.encoding.com/", :body => '', :status => ['404', 'Not Found'])
        @result = @sut.cancel_media(1234) 
      end

      it 'should return nil' do
        @result.should be_nil
      end

      it 'should have "Not Found" as an error' do
        @sut.last_error.should == 'Not Found'
      end

    end

    describe "the server returns a 500 error code" do
      before do
        FakeWeb.register_uri(:post, "http://manage.encoding.com/", :body => '', :status => ['500', 'Server Error'])
        @result = @sut.cancel_media(1234) 
      end

      it 'should return nil' do
        @result.should be_nil
      end

      it 'should have "Server Error" as an error' do
        @sut.last_error.should == 'Server Error'
      end

    end

    describe "valid cancel request" do
      before do
        @media_id = 1234
        FakeWeb.register_uri(:post, 'http://manage.encoding.com/', :body => "<?xml version=\"1.0\"?><response><message>Deleted</message></response></response>")
        @result = @sut.cancel_media(@media_id)
      end
      it 'should return truthy' do

        @result.should be true
      end
    end

  end

end
