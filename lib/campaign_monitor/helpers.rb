class CampaignMonitor
  module Helpers
    def self.included(base)
      base.class_eval do 
        extend ClassMethods
        include InstanceMethods
      end
    end

    module ClassMethods
    end  
  
    module InstanceMethods  
    end
  end
  
end