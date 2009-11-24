require 'rubygems'
require 'uri'
require 'net/http'
require 'rexml/document'
require 'builder'


class RubyEncodingWrapper
  attr_reader :user_id, :user_key, :url
  
  def initialize(user_id=nil, user_key=nil)
    @user_id = user_id
    @user_key = user_key
    @url = 'http://manage.encoding.com:80'

  end

  def request_encoding(action=nil, source=nil, format={})
    #{ :size, :bitrate, :audio_bitrate, :audio_sample_rate, :audio_channels_number, :framerate, :two_pass, :cbr, :deinterlacing, :destination, :add_meta

    builder = Builder::XmlMarkup.new(:target=>STDOUT, :indent=>2)
    builder.query do |q|
      q.userid(@user_id);
      q.userid @user_id
      q.userkey @user_key
      q.action action
      q.source source
      q.format format
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