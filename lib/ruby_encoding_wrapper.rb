require 'rubygems'
require 'uri'
require 'net/http'
require 'builder'
require 'rexml/document'
require 'nokogiri'

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

module RequestResponse
  ERROR = nil
end

class RubyEncodingWrapper
  attr_reader :user_id, :user_key, :url, :last_error

  def initialize(user_id=nil, user_key=nil)
    @user_id = user_id
    @user_key = user_key
    @url = 'http://manage.encoding.com/'
  end

  def request_encoding(source=nil, notify_url=nil)
    #{ :size, :bitrate, :audio_bitrate, :audio_sample_rate,
    #:audio_channels_number, :framerate, :two_pass, :cbr,
    #:deinterlacing, :destination, :add_meta
    
    xml = Builder::XmlMarkup.new :indent=>2
    xml.instruct! 
    xml.query do |q|
      q.userid  @user_id
      q.userkey @user_key
      q.action  EncodingActions::ADD_MEDIA
      q.source  source
      q.notify  notify_url

      yield q
    end

    response = request_send(xml.target!)
    return RequestResponse::ERROR if request_error?(response)

    document = Nokogiri::XML(response.body)
    return RequestResponse::ERROR if api_error?(document)

    document.css("MediaID").text.to_i
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
    return RequestResponse::ERROR if request_error?(response)

    document = Nokogiri::XML(response.body)
    return RequestResponse::ERROR if api_error?(document)

    root = document.root

    status = root.elements["status"][0].to_s
    progress = root.elements["progress"][0].to_s.to_i

    # there is a bug where the progress reports
    # as 100% if the status is 'Waiting for encoder'
    if (status == EncodingStatusType::WAITING)
      progress = 0
    end

    status = { 
      :message => status,
      :progress => progress
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
    return RequestResponse::ERROR if request_error?(response)

    document = Nokogiri::XML(response.body)
    return RequestResponse::ERROR if api_error?(document)
    
    true

  end


  private

  def request_error?(response)
    if response.code =~ /(4|5)\d+/
      @last_error = response.message
      true
    else
      false
    end
  end

  def api_error?(document)

    # puts document.inspect
    if document.css('errors error').length > 0
      @last_error = document.css('errors error').text
      true
    else
      false
    end
  end

  def request_send(xml)
    url = URI.parse(@url)
    request = Net::HTTP::Post.new(url.path)
    request.form_data = { :xml => xml }

    Net::HTTP.new(url.host, url.port).start { |http|
      http.request(request)
    }
  end
    
end
