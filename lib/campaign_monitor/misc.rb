class CampaignMonitor

  # Encapsulates
  class SubscriberBounce #:nodoc:
    attr_reader :email_address, :bounce_type, :list_id

    def initialize(email_address, list_id, bounce_type)
      @email_address = email_address
      @bounce_type = bounce_type
      @list_id = list_id
    end
  end

  # Encapsulates
  class SubscriberOpen #:nodoc:
    attr_reader :email_address, :list_id, :opens

    def initialize(email_address, list_id, opens)
      @email_address = email_address
      @list_id = list_id
      @opens = opens
    end
  end

  # Encapsulates
  class SubscriberClick #:nodoc:
    attr_reader :email_address, :list_id, :clicked_links

    def initialize(email_address, list_id, clicked_links)
      @email_address = email_address
      @list_id = list_id
      @clicked_links = clicked_links
    end
  end

  # Encapsulates
  class SubscriberUnsubscribe #:nodoc:
    attr_reader :email_address, :list_id

    def initialize(email_address, list_id)
      @email_address = email_address
      @list_id = list_id
    end
  end

end