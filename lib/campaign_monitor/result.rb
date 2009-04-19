class CampaignMonitor
  # Encapsulates the response received from the CampaignMonitor webservice.
  class Result
    attr_reader :message, :code, :raw

    def initialize(response)
      @message = response["Message"]
      @code = response["Code"].to_i
      @raw = response
    end

    def success?
      code == 0
    end

    def failed?
      not success?
    end

    def content
      # if we're a string (likely from SOAP)
      return raw if raw.is_a?(String)
      # if we're a hash
      raw["__content__"]
    end

    alias :succeeded? :success?
    alias :failure? :failed?

  end
end