class CampaignMonitor
  # Provides access to the information about a campaign
  class Campaign
    attr_reader :id, :subject, :sent_date, :total_recipients

    def initialize(id=nil, subject=nil, sent_date=nil, total_recipients=nil)
      @id = id
      @subject = subject
      @sent_date = sent_date
      @total_recipients = total_recipients
      @cm_client = CampaignMonitor.new
    end

    # Example
    #  @campaign = Campaign.new(12345)
    #  @subscriber_opens = @campaign.opens
    #
    #  for subscriber in @subscriber_opens
    #    puts subscriber.email
    #  end
    def opens
      response = @cm_client.Campaign_GetOpens("CampaignID" => @id)
      return [] if response.empty?
      unless response["Code"].to_i != 0
        response["SubscriberOpen"].collect{|s| SubscriberOpen.new(s["EmailAddress"], s["ListID"].to_i, s["NumberOfOpens"])}
      else
        raise response["Code"] + " - " + response["Message"]
      end
    end

    # Example
    #  @campaign = Campaign.new(12345)
    #  @subscriber_bounces = @campaign.bounces
    #
    #  for subscriber in @subscriber_bounces
    #    puts subscriber.email
    #  end
    def bounces
      response = @cm_client.Campaign_GetBounces("CampaignID"=> @id)
      return [] if response.empty?
      unless response["Code"].to_i != 0
        response["SubscriberBounce"].collect{|s| SubscriberBounce.new(s["EmailAddress"], s["ListID"].to_i, s["BounceType"])}
      else
        raise response["Code"] + " - " + response["Message"]
      end
    end

    # Example
    #  @campaign = Campaign.new(12345)
    #  @subscriber_clicks = @campaign.clicks
    #
    #  for subscriber in @subscriber_clicks
    #    puts subscriber.email
    #  end
    def clicks
      response = @cm_client.Campaign_GetSubscriberClicks("CampaignID" => @id)
      return [] if response.empty?
      unless response["Code"].to_i != 0
        response["SubscriberClick"].collect{|s| SubscriberClick.new(s["EmailAddress"], s["ListID"].to_i, s["ClickedLinks"])}
      else
        raise response["Code"] + " - " + response["Message"]
      end
    end

    # Example
    #  @campaign = Campaign.new(12345)
    #  @subscriber_unsubscribes = @campaign.unsubscribes
    #
    #  for subscriber in @subscriber_unsubscribes
    #    puts subscriber.email
    #  end
    def unsubscribes
      response = @cm_client.Campaign_GetUnsubscribes("CampaignID" => @id)
      return [] if response.empty?
      unless response["Code"].to_i != 0
        response["SubscriberUnsubscribe"].collect{|s| SubscriberUnsubscribe.new(s["EmailAddress"], s["ListID"].to_i)}
      else
        raise response["Code"] + " - " + response["Message"]
      end
    end

    # Example
    #  @campaign = Campaign.new(12345)
    #  puts @campaign.number_recipients
    def number_recipients
      @number_recipients.nil? ? getInfo.number_recipients : @number_recipients
    end

    # Example
    #  @campaign = Campaign.new(12345)
    #  puts @campaign.number_opened
    def number_opened
      @number_opened.nil? ? getInfo.number_opened : @number_opened
    end

    # Example
    #  @campaign = Campaign.new(12345)
    #  puts @campaign.number_clicks
    def number_clicks
      @number_clicks.nil? ? getInfo.number_clicks : @number_clicks
    end

    # Example
    #  @campaign = Campaign.new(12345)
    #  puts @campaign.number_unsubscribed
    def number_unsubscribed
      @number_unsubscribed.nil? ? getInfo.number_unsubscribed : @number_unsubscribed
    end

    # Example
    #  @campaign = Campaign.new(12345)
    #  puts @campaign.number_bounced
    def number_bounced
      @number_bounced.nil? ? getInfo.number_bounced : @number_bounced
    end

    private
      def getInfo
        info = @cm_client.Campaign_GetSummary('CampaignID'=>@id)
        @title = info['title']
        @number_recipients = info["Recipients"].to_i
        @number_opened = info["TotalOpened"].to_i
        @number_clicks = info["Click"].to_i
        @number_unsubscribed = info["Unsubscribed"].to_i
        @number_bounced = info["Bounced"].to_i
        self
      end
  end
end