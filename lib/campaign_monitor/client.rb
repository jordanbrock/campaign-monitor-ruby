class CampaignMonitor
  # Provides access to the lists and campaigns associated with a client
  class Client
    include Helpers

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
      handle_response(cm_client.Client_GetLists("ClientID" => self.id)) do |response|
        response["List"].collect{|l| List.new(l["ListID"], l["Name"])}
      end
    end

    # Example
    #  @client = new Client(12345)
    #  @campaigns = @client.campaigns
    #
    #  for campaign in @campaigns
    #    puts campaign.subject
    #  end
    def campaigns
      handle_response(cm_client.Client_GetCampaigns("ClientID" => self.id)) do |response|
        response["Campaign"].collect{|c| Campaign.new(c["CampaignID"], c["Subject"], c["SentDate"], c["TotalRecipients"].to_i)}
      end
    end
  end
end