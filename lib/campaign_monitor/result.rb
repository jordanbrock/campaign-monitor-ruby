class CampaignMonitor
  # Encapsulates the response received from the CampaignMonitor webservice.
  class Result
    attr_reader :message, :code

    def initialize(message, code)
      @message = message
      @code = code
    end
  end
end