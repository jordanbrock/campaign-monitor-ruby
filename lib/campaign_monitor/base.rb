class CampaignMonitor
  # Provides access to the lists and campaigns associated with a client
  class Base

    attr_reader :result, :attributes, :cm_client

    @@client=nil

    def self.client
      @@client
    end
    
    def self.client=(a)
      @@client=a
    end
    
    def [](k)
      if m=self.class.get_data_types[k]
        @attributes[k].send(m)
      else
        @attributes[k]
      end
    end
    
    def []=(k,v)
      @attributes[k]=v
    end
    
    def initialize(*args)
      @attributes={}
      @cm_client=@@client
    end
    
    # id and name field stuff
    
    inherited_property "id_field", "id"
    inherited_property "name_field", "name"
    inherited_property "data_types", {}
    
    def id
      @attributes[self.class.get_id_field]
    end
    
    def id=(v)
      @attributes[self.class.get_id_field]=v
    end
    
    def name
      @attributes[self.class.get_name_field]
    end
    
  end
  
end
    