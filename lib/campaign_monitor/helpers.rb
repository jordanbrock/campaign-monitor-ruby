class CampaignMonitor
  module Helpers

    def handle_response(response)      
      return [] if response.empty?

      if response["Code"].to_i == 0
        # success!
        yield(response)
      elsif response["Code"].to_i == 100
        raise InvalidAPIKey
      else
        # error!
        raise ApiError, response["Code"] + ": " + response["Message"]
      end      
    end

    def timestamp_format
      '%Y-%m-%d %H:%M:%S'
    end

    def formatted_timestamp(datetime, format=timestamp_format)
      datetime.strftime(format)
    end
    
  end
end