class CampaignMonitor
  # Provides access to the information about a campaign
  class Campaign
    include CampaignMonitor::Helpers
    
    attr_reader :id, :subject, :sent_date, :total_recipients, :cm_client

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
      handle_response(cm_client.Campaign_GetOpens("CampaignID" => self.id)) do |response|
        response["SubscriberOpen"].collect{|s| SubscriberOpen.new(s["EmailAddress"], s["ListID"], s["NumberOfOpens"])}
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
      handle_response(cm_client.Campaign_GetBounces("CampaignID"=> self.id)) do |response|
        response["SubscriberBounce"].collect{|s| SubscriberBounce.new(s["EmailAddress"], s["ListID"], s["BounceType"])}
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
      handle_response(cm_client.Campaign_GetSubscriberClicks("CampaignID" => self.id)) do |response|
        response["SubscriberClick"].collect{|s| SubscriberClick.new(s["EmailAddress"], s["ListID"], s["ClickedLinks"])}
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
      handle_response(cm_client.Campaign_GetUnsubscribes("CampaignID" => self.id)) do |response|
        response["SubscriberUnsubscribe"].collect{|s| SubscriberUnsubscribe.new(s["EmailAddress"], s["ListID"])}
      end
    end

    # Example
    #  @campaign = Campaign.new(12345)
    #  puts @campaign.number_recipients
    def number_recipients
      @number_recipients ||= attributes[:number_recipients]
    end

    # Example
    #  @campaign = Campaign.new(12345)
    #  puts @campaign.number_opened
    def number_opened
      @number_opened ||= attributes[:number_opened]
    end

    # Example
    #  @campaign = Campaign.new(12345)
    #  puts @campaign.number_clicks
    def number_clicks
      @number_clicks ||= attributes[:number_clicks]
    end

    # Example
    #  @campaign = Campaign.new(12345)
    #  puts @campaign.number_unsubscribed
    def number_unsubscribed
      @number_unsubscribed ||= attributes[:number_unsubscribed]
    end

    # Example
    #  @campaign = Campaign.new(12345)
    #  puts @campaign.number_bounced
    def number_bounced
      @number_bounced ||= attributes[:number_bounced]
    end

    private
      def attributes
        if @attributes.nil?
          summary = cm_client.Campaign_GetSummary('CampaignID' => self.id)
          @attributes = {
            :number_recipients   => summary['Recipients'].to_i,
            :number_opened       => summary['TotalOpened'].to_i,
            :number_clicks       => summary['Click'].to_i,
            :number_unsubscribed => summary['Unsubscribed'].to_i,
            :number_bounced      => summary['Bounced'].to_i
          }
        end
        
        @attributes
      end
  end
end