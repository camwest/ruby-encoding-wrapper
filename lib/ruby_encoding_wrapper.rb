require 'rubygems'
require 'uri'
require 'net/http'
require 'builder'

class RubyEncodingWrapper
  
  def initialize(user_id=nil,user_key=nil)
    self.userid = user_id
    self.userkey = user_key
    self.url = 'manage.encoding.com:80'
  end

  def request_encoding(action,source,format={})
    #xml generation
    xml.instruct! :xml, :version => "1.1", :encoding => "UTF-8"
    xml.userid 'id'
    xml.userkey 'key'
    xml.action 'AddMedia'
    xml.source @video
    xml.format do
      
    end

   
    request_send(xml)
  end


  private
  def request_send(xml)
    url = URI.parse('http://localhost:3000/someservice/')
    request = Net::HTTP::Post.new(url.path)
    request.body = "<?xml version='1.0' encoding='UTF-8'?><somedata><name>Test Name 1</name><description>Some data for Unit testing</description></somedata>"
    response = Net::HTTP.start(url.host, url.port) {|http| http.request(request)}
  end
end