class CampaignMonitor
  # Encapsulates the response received from the CampaignMonitor webservice.
  class Result
    attr_reader :message, :code

    def initialize(response)
      @message = response["Message"]
      @code = response["Code"].to_i
    end

    def succeeded?
      code == 0
    end

    def failed?
      !succeeded?
    end
  end
end