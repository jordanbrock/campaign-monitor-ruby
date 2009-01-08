class CampaignMonitor
  # Provides the ability to add/remove subscribers from a list
  class Subscriber
    include CampaignMonitor::Helpers

    attr_accessor :email_address, :name, :date_subscribed
    attr_reader :cm_client

    def initialize(email_address, name=nil, date=nil)
      @email_address = email_address
      @name = name
      @date_subscribed = date_subscribed
      @cm_client = CampaignMonitor.new
    end

    # Example
    #  @subscriber = Subscriber.new("ralph.wiggum@simpsons.net")
    #  @subscriber.add(12345)
    def add(list_id)
      Result.new(cm_client.Subscriber_Add("ListID" => list_id, "Email" => @email_address, "Name" => @name))
    end

    # Example
    #  @subscriber = Subscriber.new("ralph.wiggum@simpsons.net")
    #  @subscriber.add_and_resubscribe(12345)
    def add_and_resubscribe(list_id)
      Result.new(cm_client.Subscriber_AddAndResubscribe("ListID" => list_id, "Email" => @email_address, "Name" => @name))
    end

    # Example
    #  @subscriber = Subscriber.new("ralph.wiggum@simpsons.net")
    #  @subscriber.unsubscribe(12345)
    def unsubscribe(list_id)
      Result.new(cm_client.Subscriber_Unsubscribe("ListID" => list_id, "Email" => @email_address))
    end

    def is_subscribed?(list_id)
      result = cm_client.Subscribers_GetIsSubscribed("ListID" => list_id, "Email" => @email_address)
      return true if result == 'True'
      return false if result == 'False'
      raise "Invalid value for is_subscribed?: #{result}"
    end
  end
end