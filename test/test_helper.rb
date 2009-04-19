require 'ruby-debug'
require 'digest'

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
  
  def assert_success(result)
    assert result.succeeded?, "#{result.code}: #{result.message}"
  end
  
  def secure_digest(*args)
    Digest::SHA1.hexdigest(args.flatten.join('--'))
  end
  
end