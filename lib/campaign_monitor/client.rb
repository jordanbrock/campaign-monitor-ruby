class CampaignMonitor
  # Provides access to the lists and campaigns associated with a client
  class ClientLists < Array
    def initialize(v,parent)
      @parent=parent
      super(v)
    end
    def build(attrs={})
      List.new(attrs.merge(:ClientID => @parent.id))
    end
  end

  # The Client class aims to impliment the full functionality of the CampaignMonitor 
  # Clients API as detailed at: http://www.campaignmonitor.com/api/
  # === Attributes
  #
  # Attriutes can be read and set as if Client were a Hash
  #
  #   @client["CompanyName"]="Road Running, Inc."
  #   @client["ContactName"] => "Wiley Coyote"
  #
  # Convenience attribute readers are provided for name and id
  #
  #   @client.id == @client["ClientID"]
  #   @client.name == @client["CompanyName"]
  #
  # === API calls supported
  # 
  # * Client.Create
  # * Client.Delete
  # * Client.GetCampaigns
  # * Client.GetDetail
  # * Client.GetLists
  # * Client.UpdateAccessAndBilling
  # * Client.UpdateBasics
  # 
  # === Not yet supported
  #
  # * Client.GetSegments - TODO
  # * Client.GetSuppressionList - TODO
  class Client < Base
    include CampaignMonitor::Helpers
    id_field "ClientID"
    name_field "CompanyName"

    data_types "AccessLevel" => "to_i"

    # we will assume if something isn't a basic attribute that it's a AccessAndBilling attribute
    BASIC_ATTRIBUTES=%w{CompanyName ContactName EmailAddress Country Timezone}

    # Creates a new client that you can later create (or load)
    # The prefered way to load a client is using Client#[] however
    #
    # Example
    #
    #  @client = Client.new(attributes)
    #  @client.Create
    #
    #  @client = Client.new("ClientID" => 12345)
    #  @client.GetDetails
    def initialize(attrs={})
      super
      @attributes=attrs
    end

    # Calls Client.GetLists and returns a collection of CM::Campaign objects
    #
    # Example
    #  @client = @cm.clients.first
    #  @new_list = @client.lists.build
    #  @lists = @client.lists
    #
    #  for list in @lists
    #    puts list.name # a shortcut for list["Title"]
    #  end
    def GetLists
      ClientLists.new(cm_client.lists(self.id), self)
    end

    alias lists GetLists

    # Calls Client.GetCampaigns and returns a collection of CM::List objects
    #
    # Example
    #  @client = @cm.clients.first
    #  @campaigns = @client.campaigns
    #
    #  for campaign in @campaigns
    #    puts campaign.subject
    #  end
    def GetCampaigns
      cm_client.campaigns(self.id)
    end

    alias campaigns GetCampaigns
    
    def new_campaign(attrs={})
      Campaign.new(attrs.merge("ClientID" => self.id))
    end
    
    
    # Calls Client.GetDetails to load a specific client
    # Client#result will have the result of the API call
    #
    # Example
    # 
    #   @client=Client[12345]
    #   puts @client.name if @client.result.success?
    def self.[](id)
      client=self.new("ClientID" => id)
      client.GetDetail(true)
      client.result.code == 102 ? nil : client
    end
  
    # Calls Client.GetDetails
    # This is needed because often if you're working with a list of clients you really only
    # have their company name when what you want is the full record.
    # It will return true if successful and false if not.
    # Client#result will have the result of the API call
    #
    # Example
    #
    #   @client=@cm.clients.first
    #   @client["CompanyName"]="Ben's Widgets"
    #   @client["ContactName"] => nil
    #   @client.GetDetail
    #   @client["ContactName"] => "Ben Wilder"
    def GetDetail(overwrite=false)
      @result=Result.new(cm_client.Client_GetDetail("ClientID" => id))
      return false if @result.failed?
      @flatten={}
      @flatten.merge!(@result.raw["BasicDetails"])
      @flatten.merge!(@result.raw["AccessAndBilling"])
      # TODO - look into
      # map {} to nil - some weird XML converstion issue?
      @flatten=@flatten.inject({}) { |sum,a| sum[a[0]]=a[1]=={} ? nil : a[1]; sum }
      @attributes=@flatten.merge(@attributes)
      @attributes.merge!(@flatten) if overwrite
      @fully_baked=true if @result.success?
      @result.success?
    end
    
    # This is just a convenience method that calls both Client.UpdateBasics and Client.UpdateAccessAndBilling.
    # It will return true if successful and false if not.
    # Client#result will have the result of the API call
    #
    # Example
    #   @client=@cm.clients.first
    #   @client["CompanyName"]="Ben's Widgets"
    #   @client.update
    def update
      self.UpdateBasics
      self.UpdateAccessAndBilling if result.success?
      @result.success?
    end

    # Calls Client.UpdateAccessAndBilling
    # This will also call GetDetails first to prepoluate any empty fields the API call needs
    # It will return true if successful and false if not.
    # Client#result will have the result of the API call
    #
    # Example
    #   @client=@cm.clients.first
    #   @client["Currency"]="USD"
    #   @client.UpdateAccessAndBilling
    def UpdateAccessAndBilling
      fully_bake
      @result=Result.new(cm_client.Client_UpdateAccessAndBilling(@attributes))
      @result.success? 
    end

    # Calls Client.UpdateBasics
    # This will also call GetDetails first to prepoluate any empty fields the API call needs
    # It will return true if successful and false if not.
    # Client#result will have the result of the API call
    #
    # Example
    #   @client=@cm.clients.first
    #   @client["CompanyName"]="Ben's Widgets"
    #   @client.UpdateBasics
    def UpdateBasics
      fully_bake
      @result=Result.new(cm_client.Client_UpdateBasics(@attributes))
      @result.success? 
    end

    # Calls Client.Create
    # It will return true if successful and false if not.
    # Client#result will have the result of the API call
    #
    # Example
    #   @client=CampaignMonitor::Client.new
    #   @client["CompanyName"]="Ben's Widgets"
    #   @client["ContactName"]="Ben Winters"
    #   @client["Country"]=@cm.countries.first
    #   @client["Timezone"]=@cm.timezones.first
    #   ...
    #   @client.Create
    def Create
      @result=Result.new(cm_client.Client_Create(@attributes))
      self.id = @result.content if @result.success?
      @result.success?
    end

    # Calls Client.Delete.
    # It will return true if successful and false if not.
    # Client#result will have the result of the API call
    #
    # Example
    #   @client=@cm.clients.first
    #   @client.Delete
    def Delete
      @result=Result.new(cm_client.Client_Delete("ClientID" => id))
      @result.success?
    end
    
    private 

    #:nodoc:
    def fully_bake 
      unless @fully_baked
        self.GetDetail
        @fully_baked=true
      end
    end
    
  end
end