require 'spec_helper'

describe RubyEncodingWrapper do

  before(:all) do
    FakeWeb.allow_net_connect = false
  end

  before do
    FakeWeb.clean_registry
    @sut = RubyEncodingWrapper.new
  end

  describe "#request_encoding" do

    describe "invalid user id or key" do
      before do
        FakeWeb.register_uri(:post, 'http://manage.encoding.com/', :body => '<?xml version="1.0"?><response><errors><error>Wrong user id or key!</error></errors></response>')
        @result = @sut.request_encoding {|query|}
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
        FakeWeb.register_uri(:post, 'http://manage.encoding.com/', :body => '<?xml version="1.0"?><response><errors><error>No formats specified!</error></errors></response>')
        @result = @sut.request_encoding {|query|}
      end

      it "should have 'No formats specified' as an error" do
        @sut.last_error.should =~ /No formats specified/
      end
    end

    describe "no source specified" do
      before do
        FakeWeb.register_uri(:post, 'http://manage.encoding.com/', :body => '<?xml version="1.0"?><response><errors><error>Source file is not indicated!</error></errors></response>')
        @result = @sut.request_encoding do |query|
          query.format do |f|
            f.output('iphone')
          end
        end
      end

      it 'should have "Source file is not indicated" as an error' do
        @sut.last_error.should =~ /Source file is not indicated/ 
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
        FakeWeb.register_uri(:post, 'http://manage.encoding.com/', :body => '<?xml version="1.0"?><response><errors><error>Wrong user id or key!</error></errors></response>')
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

  end

  describe "#cancel_media" do

    describe "invalid user id or key" do
      before do
        FakeWeb.register_uri(:post, 'http://manage.encoding.com/', :body => '<?xml version="1.0"?><response><errors><error>Wrong user id or key!</error></errors></response>')
        @result = @sut.cancel_media(1234)
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

  end

end
