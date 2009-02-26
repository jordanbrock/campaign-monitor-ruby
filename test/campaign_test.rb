require 'rubygems'
require 'lib/campaign_monitor'
require 'test/unit'
require 'test/test_helper'

CLIENT_NAME               = 'Spacely Space Sprockets'
CLIENT_CONTACT_NAME       = 'George Jetson'
LIST_NAME                 = 'List #1'

class CampaignMonitorTest < Test::Unit::TestCase

  def setup
    @cm = CampaignMonitor.new(ENV["API_KEY"])   
    # find an existing client and make sure we know it's values
    @client=find_test_client(@cm.clients)
    assert_not_nil @client, "Please create a '#{CLIENT_NAME}' (company name) client so tests can run."

    @campaign=@client.campaigns.detect { |x| x["Subject"] == "Big Deal" }
    assert_not_nil @campaign, "Please create a campaign named 'Big Deal' so tests can run."
    
    # delete all existing lists
    @client.lists.each { |l| l.Delete }
    @list = @client.lists.build.defaults
  end
  
  def teardown
  end

  def test_finds_named_campaign
    assert_equal 1, @campaign["TotalRecipients"]
    assert_equal 1, @campaign.lists.size
    assert_equal Hash.new, @campaign.lists.first["Title"]
  end
  
  def test_bracket_lookup_for_nonexistant
    @campaign=CampaignMonitor::Campaign[12345]
    assert_not_nil @campaign
    assert_equal 12345, @campaign.id
    assert_raises( CampaignMonitor::ApiError ) { @campaign.lists }
    assert_raises( CampaignMonitor::ApiError ) { @campaign.GetSummary }
  end
  
  def test_bracket_lookup_for_existing
    camp=CampaignMonitor::Campaign[@campaign.id]
    assert_not_nil camp
    camp.lists
  end
  
  def test_summary_interface
    @campaign=@client.campaigns.detect { |x| x["Subject"] == "Big Deal" }
    assert_not_nil @campaign
    # old
    assert_equal 1, @campaign.number_recipients
    assert_equal 0, @campaign.number_opened
    assert_equal 0, @campaign.number_clicks
    assert_equal 0, @campaign.number_unsubscribed
    assert_equal 0, @campaign.number_bounced
    # new
    assert_equal 1, @campaign.summary["Recipients"]
    assert_equal 0, @campaign.summary["TotalOpened"]
    assert_equal 0, @campaign.summary["Clicks"]
    assert_equal 0, @campaign.summary["Unsubscribed"]
    assert_equal 0, @campaign.summary["Bounced"]
  end
  
  def test_creating_a_campaign
    return
    @campaign=@client.new_campaign
    # create two lists
    @beef=@client.lists.build.defaults
    @beef["Title"]="Beef"
    @beef.Create
    assert_success @beef.result
    @chicken=@client.lists.build.defaults
    @chicken["Title"]="Chicken"
    @chicken.Create
    assert_success @chicken.result

    @campaign.lists << @beef
    @campaign.lists << @chicken
    @campaign["CampaignName"]="Noodles #{secure_digest(Time.now.to_s)}"
    @campaign["CampaignSubject"]="Noodly #{secure_digest(Time.now.to_s)}"
    puts @campaign.inspect
    @campaign["FromName"] = "George Bush"
    @campaign["FromEmail"] = "george@aol.com"
    @campaign["ReplyTo"] = "george@aol.com"
    @campaign["HtmlUrl"] = "http://www.google.com/robots.txt"
    @campaign["TextUrl"] = "http://www.google.com/robots.txt"
    @campaign.Create
    puts @campaign.result.inspect
    assert_success @campaign.result
    assert_not_nil @campaign.id
    assert_equal 32, @campaign.id.length
    # test GetLists
    @campaign.instance_variable_set("@lists",nil)
    assert_equal 2, @campaign.lists.size
    # test sending
    @campaign.Send("ConfirmationEmail" => "george@aol.com", "SendDate" => "Immediately")
    assert_success @campaign.result
  end
  
  def test_GetSummary
    @campaign=@client.campaigns.detect { |x| x["Subject"] == "Big Deal" }
    assert_not_nil @campaign
    @campaign.GetSummary
    assert @campaign.result.success?
  end

  
  protected
    
    def find_test_client(clients)
      clients.detect { |c| c.name == CLIENT_NAME }
    end
    
end