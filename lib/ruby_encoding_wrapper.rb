require 'rubygems'
require 'uri'
require 'net/http'
require 'builder'
require 'rexml/document'


class RubyEncodingWrapper
  attr_reader :user_id, :user_key, :url
  
  def initialize(user_id=nil, user_key=nil)
    @user_id = user_id
    @user_key = user_key
    @url = 'manage.encoding.com:80'

  end

  def request_encoding(action=nil, source=nil, format={})
    #{ :size, :bitrate, :audio_bitrate, :audio_sample_rate, :audio_channels_number, :framerate, :two_pass, :cbr, :deinterlacing, :destination, :add_meta

    xml = Builder::XmlMarkup.new(:target=>STDOUT, :indent=>2)
    xml.query do |q|
      q.userid(@user_id)
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
      url = URI.parse(@url)      
      Net::HTTP.start(url.host, url.port) do |http|
        response = http.post(url.path, "xml=#{xml}")
      end
    end
end