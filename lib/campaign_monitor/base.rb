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
    
    def [](k)
      @attributes[k]
    end
    
    def []=(k,v)
      @attributes[k]=v
    end
    
    def initialize(*args)
      @attributes={}
      @cm_client=@@client
    end
  end
  
end
    