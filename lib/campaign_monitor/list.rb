require 'soap/wsdlDriver'

class CampaignMonitor
  # Provides access to the subscribers and info about subscribers
  # associated with a Mailing List
  class List
    include CampaignMonitor::Helpers

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
    def add_subscriber(email, name=nil, custom_fields=nil)
      if custom_fields.nil?
        Result.new(cm_client.Subscriber_Add("ListID" => self.id, "Email" => email, "Name" => name))
      else
        add_subscriber_with_custom_fields(email, name, custom_fields)
      end
    end
    
    def add_and_resubscribe(email, name=nil, custom_fields=nil)
      if custom_fields.nil?
        Result.new(cm_client.Subscriber_AddAndResubscribe("ListID" => self.id, "Email" => email, "Name" => name))        
      else
        add_and_resubscribe_with_custom_fields(email, name, custom_fields)
      end
    end

    # Example
    #  @list = new List(12345)
    #  result = @list.remove_subscriber("ralph.wiggum@simpsons.net")
    #
    #  if result.succeeded?
    #    puts "Deleted Subscriber"
    #  end
    def remove_subscriber(email)
      Result.new(cm_client.Subscriber_Unsubscribe("ListID" => self.id, "Email" => email))
    end

    # email           The subscriber's email address.
    # name            The subscriber's name.
    # custom_fields   A hash of field name => value pairs.
    def add_subscriber_with_custom_fields(email, name, custom_fields)
      response = cm_client.using_soap do |driver|
        driver.addSubscriberWithCustomFields \
            :ApiKey       => cm_client.api_key,
            :ListID       => self.id,
            :Email        => email,
            :Name         => name,
            :CustomFields => { :SubscriberCustomField => custom_fields_array(custom_fields) }
      end
      
      response.subscriber_AddWithCustomFieldsResult
    end

    # email           The subscriber's email address.
    # name            The subscriber's name.
    # custom_fields   A hash of field name => value pairs.
    def add_and_resubscribe_with_custom_fields(email, name, custom_fields)      
      response = cm_client.using_soap do |driver|
        driver.addAndResubscribeWithCustomFields \
            :ApiKey       => cm_client.api_key,
            :ListID       => self.id,
            :Email        => email,
            :Name         => name,
            :CustomFields => { :SubscriberCustomField => custom_fields_array(custom_fields) }
      end

      response.subscriber_AddAndResubscribeWithCustomFieldsResult
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
      response = cm_client.Subscribers_GetActive('ListID' => self.id, 'Date' => formatted_timestamp(date))
      handle_response(response) do
        response['Subscriber'].collect{|s| Subscriber.new(s['EmailAddress'], s['Name'], s['Date'])}
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
      date = formatted_timestamp(date) unless date.is_a?(String)
      
      response = cm_client.Subscribers_GetUnsubscribed('ListID' => self.id, 'Date' => date)
      
      handle_response(response) do
        response['Subscriber'].collect{|s| Subscriber.new(s['EmailAddress'], s['Name'], s['Date'])}
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
      response = cm_client.Subscribers_GetBounced('ListID' => self.id, 'Date' => formatted_timestamp(date))

      handle_response(response) do
        response["Subscriber"].collect{|s| Subscriber.new(s["EmailAddress"], s["Name"], s["Date"])}        
      end
    end
    

    protected
    
      # Converts hash of custom field name/values to array of hashes for the SOAP API.
      def custom_fields_array(custom_fields)
        arr = []
        custom_fields.each do |key, value|
          arr << { "Key" => key, "Value" => value }
        end
        arr
      end

  end
end