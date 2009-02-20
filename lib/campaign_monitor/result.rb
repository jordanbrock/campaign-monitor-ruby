class CampaignMonitor
  # Encapsulates the response received from the CampaignMonitor webservice.
  class Result
    attr_reader :message, :code

    def initialize(response)
      @message = response["Message"]
      @code = response["Code"].to_i
      @raw=response
    end

    def success?
      code == 0
    end

    def failed?
      !succeeded?
    end

    def content
      raw["__content__"]
    end

    alias :succeeded? :success?
    alias :failure? :failed?

    def raw
      @raw
    end

  end
end