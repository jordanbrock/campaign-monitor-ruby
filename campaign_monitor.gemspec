Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.name = 'campaign_monitor'
  s.version = "1.1"
  s.summary = 'Provides access to the Campaign Monitor API.'
  s.description = 'A simple wrapper class that provides basic access to the Campaign Monitor API.'
  s.authors = ['Jeremy Weiskotten']
  s.email = 'jweiskotten@patientslikeme.com'
  s.homepage = 'http://github.com/patientslikeme/campaign_monitor/'
  s.has_rdoc = true
  
  s.requirements << 'none'
  s.require_path = 'lib'

  s.files = [
        "Rakefile",
        "README.rdoc",
        "campaign_monitor.gemspec",
        "lib/campaign_monitor.rb",
        "lib/campaign_monitor/campaign.rb",
        "lib/campaign_monitor/client.rb",
        "lib/campaign_monitor/list.rb",
        "lib/campaign_monitor/result.rb",
        "lib/campaign_monitor/subscriber.rb",
      ]

  s.test_files = [
      ]
end