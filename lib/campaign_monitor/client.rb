class CampaignMonitor
  # Provides access to the lists and campaigns associated with a client
  class Client
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
      response = @cm_client.Client_GetLists("ClientID" => @id)
      return [] if response.empty?
      unless response["Code"].to_i != 0
        response["List"].collect{|l| List.new(l["ListID"].to_i, l["Name"])}
      else
        raise response["Code"] + " - " + response["Message"]
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
      response = @cm_client.Client_GetCampaigns("ClientID" => @id)
      unless response["Code"].to_i != 0
        response["Campaign"].collect{|c| Campaign.new(c["CampaignID"].to_i, c["Subject"], c["SentDate"], c["TotalRecipients"].to_i)}
      else
        raise response["Code"] + " - " + response["Message"]
      end
    end
  end
end