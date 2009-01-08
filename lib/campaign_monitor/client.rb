class CampaignMonitor
  # Provides access to the lists and campaigns associated with a client
  class Client
    include CampaignMonitor::Helpers

    attr_reader :id, :name, :cm_client

    # Example
    #  @client = new Client(12345)
    def initialize(id, name=nil)
      @id = id
      @name = name
      @cm_client = CampaignMonitor.new
    end

    # Example
    #  @client = new Client(12345)
    #  @lists = @client.lists
    #
    #  for list in @lists
    #    puts list.name
    #  end
    def lists
      cm_client.lists(self.id)
    end

    # Example
    #  @client = new Client(12345)
    #  @campaigns = @client.campaigns
    #
    #  for campaign in @campaigns
    #    puts campaign.subject
    #  end
    def campaigns
      cm_client.campaigns(self.id)
    end
  end
end