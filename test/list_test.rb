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
    assert_not_nil @client, "Please create a '#{CLIENT_NAME}' (company name) client so tests can run."
    
    # delete all existing lists
    @client.lists.each { |l| l.Delete }
    @list = @client.lists.build.defaults
    @list["Title"]="List #1"
    assert @list.Create    
  end
  
  def teardown
    @list.Delete
  end
  
  def test_create_and_delete_list
    list = @client.lists.build.defaults
    list["Title"]="This is a new list"
    list.Create
    assert_success list.result
    assert_not_nil list.id
    assert_equal 0, list.active_subscribers(Date.new(2005,1,1)).size
    saved_id=list.id
    # find it all over again
    list=@client.lists.detect { |x| x.name == "This is a new list" }
    assert_equal saved_id, list.id
    assert list.Delete
    assert_success list.result
    # should be gone now
    assert_nil @client.lists.detect { |x| x.name == "This is a new list" }
  end
  
  def test_update_list
    list=@client.lists.first
    assert_equal "List #1", list.name
    list["Title"]="Just another list"
    list.Update
    list=@client.lists.first
    assert_equal "Just another list", list.name
  end
  
  def test_getdetail_for_list_instance
    list=@client.lists.first
    assert_equal "List #1", list.name
    assert_nil list["ConfirmOptIn"]
    list.GetDetail
    assert_equal "false", list["ConfirmOptIn"]
  end
  
  def test_getdetail_to_load_list
    list=CampaignMonitor::List.GetDetail(@list.id)
    assert_equal "List #1", list.name
    list=CampaignMonitor::List[@list.id]
    assert_equal "List #1", list.name
  end
  
  # test that our own creative mapping of errors actually works
  def test_save_with_missing_attribute
    list = @client.lists.build
    list["Title"]="This is a new list"
    assert !list.Create
    assert list.result.failure?
    assert_equal 500, list.result.code
    assert_equal "System.InvalidOperationException: Missing parameter: UnsubscribePage.", list.result.message
  end
  
  def test_getting_a_dummy_list
    list=CampaignMonitor::List["snickers"]
    assert_equal nil, list
  end

  def test_list_add_subscriber
    list=@client.lists.first
    assert_equal 0, list.active_subscribers(Date.new(2005,1,1)).size
    assert_success list.add_and_resubscribe('a@test.com', 'Test A')
    assert_equal 1, list.active_subscribers(Date.new(2005,1,1)).size
    assert_success list.remove_subscriber('a@test.com')
  end
  

  protected
  
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