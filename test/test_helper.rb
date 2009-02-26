CAMPAIGN_MONITOR_API_KEY=nil

if ENV["API_KEY"].nil?
  puts "Please specify the API_KEY on the command line for testing."
  exit
end

class Test::Unit::TestCase #:nodoc: all
  
  def assert_not_empty(v)
    assert !v.nil?, "expected to not be empty, but was nil"
    assert !v.empty?, "expected to not be empty" if v.respond_to?(:empty?)
    assert !v.strip.empty?, "expected to not be empty" if v.is_a?(String)
  end
  
end