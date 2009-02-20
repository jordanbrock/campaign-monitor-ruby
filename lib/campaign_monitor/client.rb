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

  class Client < Base
    include CampaignMonitor::Helpers
    id_field "ClientID"
    name_field "CompanyName"

    data_types "AccessLevel" => "to_i"

    # we will assume if something isn't a basic attribute that it's a AccessAndBilling attribute
    BASIC_ATTRIBUTES=%w{CompanyName ContactName EmailAddress Country Timezone}

    attr_reader :cm_client

    # Example
    #  @client = new Client(12345)
    def initialize(attrs={})
      super
      @attributes=attrs
    end

    # Example
    #  @client = new Client(12345)
    #  @lists = @client.lists
    #
    #  for list in @lists
    #    puts list.name
    #  end
    def lists
      ClientLists.new(cm_client.lists(self.id), self)
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
    
    #######
    # API
    #######
    
    def GetDetail(overwrite=false)
      @result=Result.new(cm_client.Client_GetDetail("ClientID" => id))
      @flatten={}
      @flatten.merge!(@result.raw["BasicDetails"])
      @flatten.merge!(@result.raw["AccessAndBilling"])
      # TODO - look into
      # map {} to nil - some weird XML converstion issue?
      @flatten=@flatten.inject({}) { |sum,a| sum[a[0]]=a[1]=={} ? nil : a[1]; sum }
      @attributes=@flatten.merge(@attributes)
      @attributes.merge!(@flatten.raw) if overwrite
      @result.success?
    end
    
    # do a full update
    def update
      self.UpdateBasics
      self.UpdateAccessAndBilling if result.success?
      @result.success?
    end
    
    def UpdateAccessAndBilling
      fully_bake
      @result=Result.new(cm_client.Client_UpdateAccessAndBilling(@attributes))
      @result.success? 
    end
    
    def UpdateBasics
      fully_bake
      @result=Result.new(cm_client.Client_UpdateBasics(@attributes))
      @result.success? 
    end

    def Create
      @result=Result.new(cm_client.Client_Create(@attributes))
      self.id = @result.content 
      @result.success?
    end
    
    def Delete
      @result=Result.new(cm_client.Client_Delete("ClientID" => id))
      @result.success?
    end
    
    private 

    def fully_bake
      unless @fully_baked
        self.GetDetail
        @fully_baked=true
      end
    end
    
  end
end