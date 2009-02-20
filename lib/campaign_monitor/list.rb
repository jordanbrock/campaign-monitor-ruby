require 'soap/wsdlDriver'

class CampaignMonitor
  # Provides access to the subscribers and info about subscribers
  # associated with a Mailing List
  class List < Base
    include CampaignMonitor::Helpers

    attr_reader :id, :cm_client, :result

    # Example
    #  @list = new List(12345)
    def initialize(id=nil, name=nil,attrs={})
      defaults={"ConfirmOptIn" => "false",
        "UnsubscribePage" => "",
        "ConfirmationSuccessPage" => ""}
      super
      @id = id
      @name = name
      @attributes=defaults.merge(attrs)
      self["Title"]=name if name # override for now
    end

    # compatible with previous API
    def name
      self["Title"]
    end

    # AR like
    def save
      id ? Update : Create
    end
    
    def Update
      # TODO: need to make sure we've loaded the full record with List_GetDetail
      # so that we have the full component of attributes to write back to the API
      @attributes["ListID"] ||= id
      @result=Result.new(List_Update(@attributes))
    end
    
    def Delete
      @result=Result.new(cm_client.List_Delete("ListID" => id))
      @result.success?
    end
    
    def Create
      raw=cm_client.List_Create(@attributes)
      @result=Result.new(raw)
      @id = raw["__content__"] if raw["__content__"]
      @id ? true : false
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