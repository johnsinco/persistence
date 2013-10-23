require 'httparty'

module HttpPartyTest
  # Available options
  #   :timeout => Timeout is specified in seconds.
  #   :headers - contains string hash such has content-type: {'content-type' => 'application/xml'}
  #   :body => Body to post.
  #

  def self.included(base)
      base.extend(ClassMethods)
  end

  module ClassMethods
    def fetch(path, options = {})
      p "++++++++++++++++++ Gateway::HTTP::Client.fetch(#{path}, #{options}) +++++++++++++++++++++"

      htoptions = {}
      begin
        method = options.delete(:method) || :get
        headers = options.delete(:headers) || {}
        htoptions[:headers] = headers

        case method
        when :get
          query = options[:query] || options[:parameters] || options
          htoptions[:query] = query if query
        when :post, :put, :delete
          htoptions[:query] = options[:query] if options[:query]  
          body = options[:body] || options[:parameters] || options
          htoptions[:body] = body
        else 
          raise ArgumentError.new("you must specify a method of either :get or :post") 
        end
        
        #ActiveSupport::Notifications.instrument "fetch.httpclient", path do
        resp = HTTParty.send(method.to_sym, path, htoptions)
        #end
        
      rescue
        p $!
        raise $!
      end
      Response.new(resp)
    end
  end
end

class Response
  def initialize(response); @resp = response; end
  def headers; @resp.headers; end
  def body; @resp.body; end
  def status; @resp.code; end
  def as_hash
    @resp.parsed_response
  end
  alias :code :status
  alias :status_code :status
  
  def success?; !!(status.to_s =~ /^2/) end
  def failed?; !success?; end;
  def server_error?; !!(status.to_s =~ /^5/) end
  def client_error?; !!(status.to_s =~ /^4/) end
  def redirection?; !!(status.to_s =~ /^3/) end
end

# @abstract Exceptions which inherit from ResponseError contain the 
# response object accessible via the {#response} method.
class ResponseError < StandardError
  # Returns the response of the request that caused the Error
  # @return [Gateway::Response]
  attr_reader :response

  # Instantiate an instance of ResponseError with a Gateway::Response object
  # @param [Gateway::Response]
  def initialize(response)
    @response = response
  end
end

