class CampaignMonitor
  module Helpers
    
    def handle_response(response)      
      return [] if response.empty?

      if response["Code"].to_i == 0
        # success!
        yield(response)
      else
        # error!
        raise response["Code"] + " - " + response["Message"]
      end      
    end

    def wsdl_driver_factory
      SOAP::WSDLDriverFactory.new("#{api_url}?WSDL")
    end

    def using_soap
      driver = wsdl_driver_factory.create_rpc_driver
      response = yield(driver)
      driver.reset_stream
    end

    def timestamp_format
      '%Y-%m-%d %H:%M:%S'
    end

    def formatted_timestamp(datetime, format=timestamp_format)
      datetime.strftime(format)
    end
    
  end
end