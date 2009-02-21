require 'rubygems'
require 'campaign_monitor'
require 'test/unit'
require 'test/test_helper'

CLIENT_NAME               = 'Spacely Space Sprockets'
LIST_NAME                 = 'List #1'

class CampaignMonitorTest < Test::Unit::TestCase
  
  def setup
    @cm = CampaignMonitor.new(ENV["API_KEY"])   
    # find an existing client
    @client=find_test_client
    assert_not_nil @client, "Please create a '#{CLIENT_NAME}' (company name) client so tests can run."
  end
  
  
  # def test_create_and_delete_client
  #   before=@cm.clients.size
  #   response = @cm.Client_Create(build_new_client)
  #   puts response.inspect
  #   assert_equal before+1, @cm.clients.size 
  #   @client_id=response["__content__"]
  #   reponse = @cm.Client_Delete("ClientID" => @client_id)
  #   assert_equal before, @cm.clients.size
  # end
  
  def test_find_existing_client_by_name
    clients = @cm.clients
    assert clients.size > 0
    
    assert clients.map {|c| c.name}.include?(CLIENT_NAME), "could not find client named: #{CLIENT_NAME}"
  end
  
  def test_invalid_key
    @cm=CampaignMonitor.new("12345")
    assert_raises (CampaignMonitor::InvalidAPIKey) { @cm.clients }
  end
  
  # we should not get confused here
  def test_can_access_two_accounts_at_once
    @cm=CampaignMonitor.new("12345")
    @cm2=CampaignMonitor.new("abcdef")
    @client=@cm.new_client
    @client2=@cm.new_client
    assert_equal "12345", @client.cm_client.api_key
    assert_equal "abcdef", @client2.cm_client.api_key
  end
  
  def test_timezones
    assert_equal 90, @cm.timezones.length
  end

  def test_countries
    countries=@cm.countries
    assert_equal 246, countries.length
    assert countries.include?("United States of America")
  end
  
  
  # campaigns
  
  # def test_campaigns
  #   client = find_test_client
  #   assert client.campaigns.size > 0, "should have one campaign"
  # end
  
  
  protected
    def build_new_client(options={})
      {"CompanyName" => "Spacely Space Sprockets", "ContactName" => "George Jetson", 
        "EmailAddress" => "george@sss.com", "Country" => "United States of America",
        "TimeZone" => "(GMT-05:00) Indiana (East)"
        }.merge(options)
    end
  

    def assert_success(result)
      assert result.succeeded?, result.message      
    end
    
    def find_test_client(clients=@cm.clients)
      clients.detect { |c| c.name == CLIENT_NAME }
    end
    
    def find_test_list(lists=find_test_client.lists)
      lists.detect { |l| l.name == LIST_NAME }
    end
end