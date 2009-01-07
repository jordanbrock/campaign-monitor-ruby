require 'rubygems'
require 'campaign_monitor'
require 'test/unit'

CAMPAIGN_MONITOR_API_KEY  = 'Your API Key'
CLIENT_NAME               = '_Test'
LIST_NAME                 = '_List1'

class CampaignMonitorTest < Test::Unit::TestCase
  
  def setup
    @cm = CampaignMonitor.new    
  end
  
  def test_clients
    clients = @cm.clients
    assert clients.size > 0
    
    assert_equal CLIENT_NAME, find_test_client(clients).name
  end
  
  def test_lists
    client = find_test_client
    assert_not_nil client

    lists = client.lists
    assert lists.size > 0
    
    list = find_test_list(lists)
    assert_equal LIST_NAME, list.name
  end
  
  def test_list_add_subscriber
    list = find_test_list

    assert_success list.add_and_resubscribe('a@test.com', 'Test A')
    assert_success list.remove_subscriber('a@test.com')
  end
  
  def test_campaigns
    client = find_test_client
    assert_not_nil client.campaigns
  end
  
  
  protected
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