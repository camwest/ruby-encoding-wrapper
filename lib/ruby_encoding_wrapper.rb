require 'rubygems'
require 'uri'
require 'net/http'
require 'builder'
require 'rexml/document'

module EncodingActions
  ADD_MEDIA = "AddMedia"
  GET_STATUS = "GetStatus"
  CANCEL_MEDIA = "CancelMedia"
end

module EncodingStatusType
  NEW = "New"
  WAITING = "Waiting for encoder"
  PROCESSING = "Processing"
  SAVING = "Saving"
  FINISHED = "Finished"
  ERROR = "Error"
end

class RubyEncodingWrapper
  attr_reader :user_id, :user_key, :url

  def initialize(user_id=nil, user_key=nil)
    @user_id = user_id
    @user_key = user_key
    @url = 'http://manage.encoding.com/'

  end

  def request_encoding(action=nil, source=nil, notify_url=nil)
    #{ :size, :bitrate, :audio_bitrate, :audio_sample_rate,
    #:audio_channels_number, :framerate, :two_pass, :cbr,
    #:deinterlacing, :destination, :add_meta

    xml = Builder::XmlMarkup.new :indent=>2
    xml.instruct! 
    xml.query do |q|
      q.userid  @user_id
      q.userkey @user_key
      q.action  action
      q.source  source
      q.notify  notify_url
      q.format { |f|
        yield f
      }
    end

    response = request_send(xml.target!)
    document = REXML::Document.new(response.body)
    document.root.elements["MediaID"][0].to_s.to_i
  end

  def request_status(media_id)
    xml = Builder::XmlMarkup.new :indent=>2
    xml.instruct!
    xml.query do |q|
      q.userid    @user_id
      q.userkey   @user_key
      q.action    EncodingActions::GET_STATUS
      q.mediaid   media_id
    end

    response = request_send(xml.target!)

    document = REXML::Document.new(response.body)
    root = document.root

    status = { 
      :message => root.elements["status"][0].to_s, 
      :progress => root.elements["progress"][0].to_s
    }
  end

  def cancel_media(media_id)
    xml = Builder::XmlMarkup.new :indent => 2
    xml.instruct!
    xml.query do |q|
      q.userid    @user_id
      q.userkey   @user_key
      q.action    EncodingActions::CANCEL_MEDIA
      q.mediaid   media_id
    end

    response = request_send(xml.target!)

    RAILS_DEFAULT_LOGGER.info(response.body)
  end


  private
    def request_send(xml)
      url = URI.parse(@url)
      request = Net::HTTP::Post.new(url.path)
      request.form_data = { :xml => xml }

      response = Net::HTTP.new(url.host, url.port).start { |http|
        http.request(request)
      }
    end

end
