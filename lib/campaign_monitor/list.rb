class CampaignMonitor
  # Provides access to the subscribers and info about subscribers
  # associated with a Mailing List
  class List
    attr_reader :id, :name, :cm_client

    # Example
    #  @list = new List(12345)
    def initialize(id=nil, name=nil)
      @id = id
      @name = name
      @cm_client = CampaignMonitor.new
    end

    # Example
    #  @list = new List(12345)
    #  result = @list.add_subscriber("ralph.wiggum@simpsons.net")
    #
    #  if result.succeeded?
    #    puts "Added Subscriber"
    #  end
    def add_subscriber(email, name = nil)
      Result.new(@cm_client.Subscriber_Add("ListID" => @id, "Email" => email, "Name" => name))
    end

    # Example
    #  @list = new List(12345)
    #  result = @list.remove_subscriber("ralph.wiggum@simpsons.net")
    #
    #  if result.succeeded?
    #    puts "Deleted Subscriber"
    #  end
    def remove_subscriber(email)
      Result.new(@cm_client.Subscriber_Unsubscribe("ListID" => @id, "Email" => email))
    end

    # Example
    #  current_date = DateTime.new
    #  @list = new List(12345)
    #  @subscribers = @list.active_subscribers(current_date)
    #
    #  for subscriber in @subscribers
    #    puts subscriber.email
    #  end
    def active_subscribers(date)
      response = @cm_client.Subscribers_GetActive('ListID' => @id, "Date" => date.strftime("%Y-%m-%d %H:%M:%S"))
      return [] if response.empty?
      unless response["Code"].to_i != 0
        response["Subscriber"].collect{|s| Subscriber.new(s["EmailAddress"], s["Name"], s["Date"])}
      else
        raise response["Code"] + " - " + response["Message"]
      end
    end

    # Example
    #  current_date = DateTime.new
    #  @list = new List(12345)
    #  @subscribers = @list.unsubscribed(current_date)
    #
    #  for subscriber in @subscribers
    #    puts subscriber.email
    #  end
    def unsubscribed(date)
      response = @cm_client.Subscribers_GetUnsubscribed('ListID' => @id, 'Date' => date.strftime("%Y-%m-%d %H:%M:%S"))
      return [] if response.empty?
      unless response["Code"].to_i != 0
        response["Subscriber"].collect{|s| Subscriber.new(s["EmailAddress"], s["Name"], s["Date"])}
      else
        raise response["Code"] + " - " + response["Message"]
      end
    end

    # Example
    #  current_date = DateTime.new
    #  @list = new List(12345)
    #  @subscribers = @list.bounced(current_date)
    #
    #  for subscriber in @subscribers
    #    puts subscriber.email
    #  end
    def bounced(date)
      response = @cm_client.Subscribers_GetBounced('ListID' => @id, 'Date' => date.strftime("%Y-%m-%d %H:%M:%S"))
      return [] if response.empty?
      unless response["Code"].to_i != 0
        response["Subscriber"].collect{|s| Subscriber.new(s["EmailAddress"], s["Name"], s["Date"])}
      else
        raise response["Code"] + " - " + response["Message"]
      end
    end

  end
end