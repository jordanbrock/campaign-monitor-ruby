class CampaignMonitor
  # Provides access to the lists and campaigns associated with a client
  class Base

    @@client=nil

    def self.client
      @@client
    end

    def self.client=(a)
      @@client=a
    end
    
    def initialize(*args)
      @cm_client=@@client
    end
  end
  
end
    