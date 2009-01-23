# CampaignMonitor
# A wrapper class to access the Campaign Monitor API. Written using the wonderful
# Flickr interface by Scott Raymond as a guide on how to access remote web services
#
# For more information on the Campaign Monitor API, visit http://campaignmonitor.com/api
#
# Author::    Jordan Brock <jordan@spintech.com.au>
# Copyright:: Copyright (c) 2006 Jordan Brock <jordan@spintech.com.au>
# License::   MIT <http://www.opensource.org/licenses/mit-license.php>
#
# USAGE:
#   require 'campaign_monitor'
#   cm = CampaignMonitor.new(API_KEY)     # creates a CampaignMonitor object
#                                         # Can set CAMPAIGN_MONITOR_API_KEY in environment.rb
#   cm.clients                            # Returns an array of clients associated with
#                                         #   the user account
#   cm.campaigns(client_id)
#   cm.lists(client_id)
#   cm.add_subscriber(list_id, email, name)
#
#  CLIENT
#   client = Client.new(client_id)
#   client.lists
#   client.campaigns
#
#  LIST
#   list = List.new(list_id)
#   list.add_subscriber(email, name)
#   list.remove_subscriber(email)
#   list.active_subscribers(date)
#   list.unsubscribed(date)
#   list.bounced(date)
#
#  CAMPAIGN
#   campaign = Campaign.new(campaign_id)
#   campaign.clicks
#   campaign.opens
#   campaign.bounces
#   campaign.unsubscribes
#   campaign.number_recipients
#   campaign.number_clicks
#   campaign.number_opens
#   campaign.number_bounces
#   campaign.number_unsubscribes
#
#
#  SUBSCRIBER
#   subscriber = Subscriber.new(email)
#   subscriber.add(list_id)
#   subscriber.unsubscribe(list_id)
#
#  Data Types
#   SubscriberBounce
#   SubscriberClick
#   SubscriberOpen
#   SubscriberUnsubscribe
#   Result
#

require 'rubygems'
require 'cgi'
require 'net/http'
require 'xmlsimple'
require 'date'

require File.join(File.dirname(__FILE__), 'campaign_monitor/helpers.rb')
require File.join(File.dirname(__FILE__), 'campaign_monitor/client.rb')
require File.join(File.dirname(__FILE__), 'campaign_monitor/list.rb')
require File.join(File.dirname(__FILE__), 'campaign_monitor/subscriber.rb')
require File.join(File.dirname(__FILE__), 'campaign_monitor/result.rb')
require File.join(File.dirname(__FILE__), 'campaign_monitor/campaign.rb')

class CampaignMonitor
  include CampaignMonitor::Helpers
  
  attr_reader :api_key, :api_url
  
  # Replace this API key with your own (http://www.campaignmonitor.com/api/)
  def initialize(api_key=CAMPAIGN_MONITOR_API_KEY)
    @api_key = api_key
    @api_url = 'http://api.createsend.com/api/api.asmx'
   end
   

   # Takes a CampaignMonitor API method name and set of parameters;
   # returns an XmlSimple object with the response
  def request(method, params)
    response = PARSER.xml_in(http_get(request_url(method, params)), { 'keeproot' => false,
      'forcearray' => %w[List Campaign Subscriber Client SubscriberOpen SubscriberUnsubscribe SubscriberClick SubscriberBounce],
      'noattr' => true })
    response.delete('d1p1:type')
    response
  end

  # Takes a CampaignMonitor API method name and set of parameters; returns the correct URL for the REST API.
  def request_url(method, params={})
    params.merge!('ApiKey' => api_key)
    
    query = params.collect do |key, value|
      "#{CGI.escape(key.to_s)}=#{CGI.escape(value.to_s)}"
    end.sort * '&'
    
    "#{api_url}/#{method}?#{query}"
  end

  # Does an HTTP GET on a given URL and returns the response body
  def http_get(url)
    Net::HTTP.get_response(URI.parse(url)).body.to_s
  end

  # By overriding the method_missing method, it is possible to easily support all of the methods
  # available in the API
  def method_missing(method_id, params = {})
    request(method_id.id2name.gsub(/_/, '.'), params)
  end

  # Returns an array of Client objects associated with the API Key
  #
  # Example
  #  @cm = CampaignMonitor.new()
  #  @clients = @cm.clients
  #
  #  for client in @clients
  #    puts client.name
  #  end
  def clients
    handle_response(User_GetClients()) do |response|
      response["Client"].collect{|c| Client.new(c["ClientID"], c["Name"])}
    end
  end
  
  def system_date
    User_GetSystemDate()
  end

  def parsed_system_date
    DateTime.strptime(system_date, timestamp_format)
  end
  
  # Returns an array of Campaign objects associated with the specified Client ID
  #
  # Example
  #  @cm = CampaignMonitor.new()
  #  @campaigns = @cm.campaigns(12345)
  #
  #  for campaign in @campaigns
  #    puts campaign.subject
  #  end
  def campaigns(client_id)
    handle_response(Client_GetCampaigns("ClientID" => client_id)) do |response|
      response["Campaign"].collect{|c| Campaign.new(c["CampaignID"], c["Subject"], c["SentDate"], c["TotalRecipients"].to_i)}
    end
  end

  # Returns an array of Subscriber Lists for the specified Client ID
  #
  # Example
  #  @cm = CampaignMonitor.new()
  #  @lists = @cm.lists(12345)
  #
  #  for list in @lists
  #    puts list.name
  #  end
  def lists(client_id)
    handle_response(Client_GetLists("ClientID" => client_id)) do |response|
      response["List"].collect{|l| List.new(l["ListID"], l["Name"])}
    end
  end

  # A quick method of adding a subscriber to a list. Returns a Result object
  #
  # Example
  #  @cm = CampaignMonitor.new()
  #  result = @cm.add_subscriber(12345, "ralph.wiggum@simpsons.net", "Ralph Wiggum")
  #
  #  if result.succeeded?
  #    puts "Subscriber Added to List"
  #  end
  def add_subscriber(list_id, email, name)
    Result.new(Subscriber_Add("ListID" => list_id, "Email" => email, "Name" => name))
  end
  
  def using_soap
    driver = wsdl_driver_factory.create_rpc_driver
    response = yield(driver)
    driver.reset_stream
    
    response
  end

  # Encapsulates
  class SubscriberBounce
    attr_reader :email_address, :bounce_type, :list_id

    def initialize(email_address, list_id, bounce_type)
      @email_address = email_address
      @bounce_type = bounce_type
      @list_id = list_id
    end
  end

  # Encapsulates
  class SubscriberOpen
    attr_reader :email_address, :list_id, :opens

    def initialize(email_address, list_id, opens)
      @email_address = email_address
      @list_id = list_id
      @opens = opens
    end
  end

  # Encapsulates
  class SubscriberClick
    attr_reader :email_address, :list_id, :clicked_links

    def initialize(email_address, list_id, clicked_links)
      @email_address = email_address
      @list_id = list_id
      @clicked_links = clicked_links
    end
  end

  # Encapsulates
  class SubscriberUnsubscribe
    attr_reader :email_address, :list_id

    def initialize(email_address, list_id)
      @email_address = email_address
      @list_id = list_id
    end
  end
    
  protected

    def wsdl_driver_factory
      SOAP::WSDLDriverFactory.new("#{api_url}?WSDL")
    end
  
end

# If libxml is installed, we use the FasterXmlSimple library, that provides most of the functionality of XmlSimple
# except it uses the xml/libxml library for xml parsing (rather than REXML). 
# If libxml isn't installed, we just fall back on XmlSimple.

PARSER =
  begin
    require 'xml/libxml'
    # Older version of libxml aren't stable (bus error when requesting attributes that don't exist) so we
    # have to use a version greater than '0.3.8.2'.
    raise LoadError unless XML::Parser::VERSION > '0.3.8.2'
    $:.push(File.join(File.dirname(__FILE__), '..', 'support', 'faster-xml-simple', 'lib'))
    require 'faster_xml_simple' 
    p 'Using libxml-ruby'
    FasterXmlSimple
  rescue LoadError
    begin
      require 'rexml-expansion-fix'
    rescue LoadError => e
      p 'Cannot load rexml security patch'
    end
    XmlSimple
  end
