class CampaignMonitor
  # Encapsulates the response received from the CampaignMonitor webservice.
  class Result
    attr_reader :message, :code

    def initialize(response)
      @message = response["Message"]
      @code = response["Code"].to_i
    end

    def success?
      code == 0
    end

    alias :succeeded? :success?

    def failed?
      !succeeded?
    end
  end
end