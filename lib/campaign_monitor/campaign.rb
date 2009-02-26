class CampaignMonitor

  # The Client class aims to impliment the full functionality of the CampaignMonitor 
  # Clients API as detailed at: http://www.campaignmonitor.com/api/
  # === Attributes
  #
  # Attriutes can be read and set as if Campaign were a Hash
  #
  #   @client["CompanyName"]="Road Running, Inc."
  #   @client["ContactName"] => "Wiley Coyote"
  #
  # Convenience attribute readers are provided for name and id
  #
  #   @campaign.id == @client["CampaignID"]
  #   @campaign.name == @client["CampaignName"]
  #
  # === API calls supported
  # 
  # * Campaign.Create
  # * Campaign.Send
  # * Campaign.GetBounces
  # * Campaign.GetLists
  # * Campaign.GetOpens
  # * Campaign.GetSubscriberClicks
  # * Campaign.GetUnsubscribes
  # * Campaign.GetSummary
  # 
  # === Not yet supported
  #
  #
  class Campaign < Base
    include CampaignMonitor::Helpers
    id_field "CampaignID"
    name_field "Subject"
    
#    attr_reader :id, :subject, :sent_date, :total_recipients, :cm_client

    data_types "TotalRecipients" => "to_i"

    attr_reader :cm_client
    
    def initialize(attrs={})
      super
      @attributes=attrs
    end

    # Example
    #  @campaign = Campaign.new(12345)
    #  @subscriber_opens = @campaign.opens
    #
    #  for subscriber in @subscriber_opens
    #    puts subscriber.email
    #  end
    def GetOpens
      handle_response(cm_client.Campaign_GetOpens("CampaignID" => self.id)) do |response|
        response["SubscriberOpen"].collect{|s| SubscriberOpen.new(s["EmailAddress"], s["ListID"], s["NumberOfOpens"])}
      end
    end
    alias opens GetOpens

    # Example
    #  @campaign = Campaign.new(12345)
    #  @subscriber_bounces = @campaign.bounces
    #
    #  for subscriber in @subscriber_bounces
    #    puts subscriber.email
    #  end
    def GetBounces
      handle_response(cm_client.Campaign_GetBounces("CampaignID"=> self.id)) do |response|
        response["SubscriberBounce"].collect{|s| SubscriberBounce.new(s["EmailAddress"], s["ListID"], s["BounceType"])}
      end
    end
    alias bounces GetBounces

    # Example
    #  @campaign = Campaign.new(12345)
    #  @subscriber_clicks = @campaign.clicks
    #
    #  for subscriber in @subscriber_clicks
    #    puts subscriber.email
    #  end
    def GetSubscriberClicks
      handle_response(cm_client.Campaign_GetSubscriberClicks("CampaignID" => self.id)) do |response|
        response["SubscriberClick"].collect{|s| SubscriberClick.new(s["EmailAddress"], s["ListID"], s["ClickedLinks"])}
      end
    end
    alias clicks GetSubscriberClicks

    # Example
    #  @campaign = Campaign.new(12345)
    #  @subscriber_unsubscribes = @campaign.unsubscribes
    #
    #  for subscriber in @subscriber_unsubscribes
    #    puts subscriber.email
    #  end
    def GetUnsubscribes
      handle_response(cm_client.Campaign_GetUnsubscribes("CampaignID" => self.id)) do |response|
        response["SubscriberUnsubscribe"].collect{|s| SubscriberUnsubscribe.new(s["EmailAddress"], s["ListID"])}
      end
    end
    alias unsubscribes GetUnsubscribes

    def GetSummary
      @result=Result.new(cm_client.Campaign_GetSummary('CampaignID' => self.id))
      @summary=@result.raw if @result.success?
      @result.success?
    end

    # Example
    #  @campaign = Campaign.new(12345)
    #  puts @campaign.number_recipients
    def number_recipients
      @number_recipients ||= summary[:number_recipients]
    end

    # Example
    #  @campaign = Campaign.new(12345)
    #  puts @campaign.number_opened
    def number_opened
      @number_opened ||= summary[:number_opened]
    end

    # Example
    #  @campaign = Campaign.new(12345)
    #  puts @campaign.number_clicks
    def number_clicks
      @number_clicks ||= summary[:number_clicks]
    end

    # Example
    #  @campaign = Campaign.new(12345)
    #  puts @campaign.number_unsubscribed
    def number_unsubscribed
      @number_unsubscribed ||= summary[:number_unsubscribed]
    end

    # Example
    #  @campaign = Campaign.new(12345)
    #  puts @campaign.number_bounced
    def number_bounced
      @number_bounced ||= summary[:number_bounced]
    end

    private
      def summary
        if @summary.nil?
          summary = cm_client.Campaign_GetSummary('CampaignID' => self.id)
          @summary = {
            :number_recipients   => summary['Recipients'].to_i,
            :number_opened       => summary['TotalOpened'].to_i,
            :number_clicks       => summary['Click'].to_i,
            :number_unsubscribed => summary['Unsubscribed'].to_i,
            :number_bounced      => summary['Bounced'].to_i
          }
        end
        @summary
      end
  end
end