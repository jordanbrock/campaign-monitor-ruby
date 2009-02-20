require 'rubygems'
require 'campaign_monitor'
require 'test/unit'

CAMPAIGN_MONITOR_API_KEY  = 'Your API Key'
CLIENT_NAME               = 'Spacely Space Sprockets'
LIST_NAME                 = 'List #1'

class CampaignMonitorTest < Test::Unit::TestCase
  
  def setup
    @cm = CampaignMonitor.new(ENV["API_KEY"] || CAMPAIGN_MONITOR_API_KEY)   
    # find an existing client
    @client=find_test_client
    assert_not_nil @client, "Please create a '#{CLIENT_NAME}' client so tests can run."
    # create one list for that client
    response = @cm.List_Create(build_new_list("ClientID" => @client.id))
    @list_id=response["__content__"]
  end
  
  def teardown
    response = @cm.List_Delete("ListID" => @list_id)
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
  
  def test_create_list
    list = @client.new_list
    list["Title"]="This a new list"
    assert list.Create
    assert_success list.result
    assert_not_nil list.id
    assert_equal 0, list.active_subscribers(Date.new(2005,1,1)).size
    assert list.Delete
    assert_success list.result
  end
  
  def test_lists
    lists = @client.lists
    assert lists.size > 0
    
    assert lists.map {|l| l.name}.include?(LIST_NAME), "could not find list named: #{LIST_NAME}"
  end
  
  def test_list_add_subscriber
    list = find_test_list
    assert_equal 0, list.active_subscribers(Date.new(2005,1,1)).size
    assert_success list.add_and_resubscribe('a@test.com', 'Test A')
    assert_equal 1, list.active_subscribers(Date.new(2005,1,1)).size
    assert_success list.remove_subscriber('a@test.com')
  end
  
  def test_campaigns
    client = find_test_client
    assert client.campaigns.size > 0, "should have one campaign"
  end
  
  
  protected
    def build_new_client(options={})
      {"CompanyName" => "Spacely Space Sprockets", "ContactName" => "George Jetson", 
        "EmailAddress" => "george@sss.com", "Country" => "United States of America",
        "TimeZone" => "(GMT-05:00) Indiana (East)"
        }.merge(options)
    end
  
    def build_new_list(options={})
      {"Title" => "List #1", "ConfirmOptIn" => "false",
        "UnsubscribePage" => "",
        "ConfirmationSuccessPage" => ""}.merge(options)
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