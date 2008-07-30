#!/usr/bin/env ruby

require 'rubygems'
require 'xmlsimple'
require "pp"
require "date"
# require 'aws/s3'

require 'lib/campaign_monitor.rb'

CAMPAIGN_MONITOR_API_KEY = '37c8763721d8e2d4805a1fd6d8260d3830eaffe5'
current_date = Time.now

cm = CampaignMonitor.new
pivot = cm.clients.find { |c| c.name == 'Pivot' }
lists = pivot.lists

# lists.each { |l| pp l.active_subscribers(Date.today) }


# pivot's [{"ClientID"=>87554}]

# pivot_cm = pivot.cm_client
# lists = pivot.lists
# pp lists
# 
l = lists.first
# 
pp l.active_subscribers(current_date)
