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
  class Campaign < Base
    include CampaignMonitor::Helpers
    id_field "CampaignID"
    name_field "Subject"
    
    class MissingParameter < StandardError
    end
    
#    attr_reader :id, :subject, :sent_date, :total_recipients, :cm_client

    data_types "TotalRecipients" => "to_i"

    attr_reader :cm_client
    
    def initialize(attrs={})
      super
      @attributes=attrs
    end

    def Create
      required_params=%w{CampaignName CampaignSubject FromName FromEmail ReplyTo HtmlUrl TextUrl}
      required_params.each do |f|
        raise MissingParameter, "'#{f}' is required to call Create" unless self[f]
      end
      response = cm_client.using_soap do |driver|
        opts=attributes.merge(:ApiKey => cm_client.api_key, :SubscriberListIDs => @lists.map {|x| x.id})
        driver.createCampaign opts
      end
      @result=Result.new(response["Campaign.CreateResult"])
      self.id=@result.content if @result.success?
      @result.success?
    end
    
    def Send(options={})
      required_params=%w{ConfirmationEmail SendDate}
      required_params.each do |f|
        raise MissingParameter, "'#{f}' is required to call Send" unless options[f]
      end
      options.merge!("CampaignID" => self.id)
      @result=Result.new(@cm_client.Campaign_Send(options))
      @result.success?
    end

    def GetLists
      handle_response(@cm_client.Campaign_GetLists(:CampaignID => id)) do |response|
        @result=Result.new(response)
        if @result.success?
          @lists=response["List"].collect{|l| List.new({"ListID" => l["ListID"], "Title" => l["Name"]})}
        end
      end
    end

    def lists
      # pull down the list of lists if we have an id
      self.GetLists if @lists.nil? and id
      @lists||=[]
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
      @summary=parse_summary(@result.raw) if @result.success?
      @result.success?
    end

    # hook up the old API calls
    def method_missing(m, *args)
      if %w{number_bounced number_unsubscribed number_clicks number_opened number_recipients}.include?(m.to_s)
        summary[m]
      else
        super
      end
    end

    def summary(refresh=false)
      self.GetSummary if refresh or @summary.nil?
      @summary
    end

    private
      def parse_summary(summary)
        @summary = {
          :number_recipients   => summary['Recipients'].to_i,
          :number_opened       => summary['TotalOpened'].to_i,
          :number_clicks       => summary['Clicks'].to_i,
          :number_unsubscribed => summary['Unsubscribed'].to_i,
          :number_bounced      => summary['Bounced'].to_i
        }
        summary.each do |key, value|
          @summary[key]=value.to_i
        end
        @summary
      end
  end
end