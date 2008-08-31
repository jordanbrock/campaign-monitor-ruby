
$__cm_source_patterns = [
  '[A-Z]*', 'campaign_monitor', 'lib/**/*', 'test/**/*', 'doc/**/*', 'init.rb', 'install.rb'
]

spec = Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.name = 'campaign_monitor'
  s.version = "1.0"
  s.summary = 'Provides access to the Campaign Monitor API'
  s.description = <<-EOF
    A simple wrapper class that provides basic access to the Campaign Monitor API
  EOF
  s.author = 'Jordan Brock'
  s.email = 'jordanbrock@gmail.com'
  s.rubyforge_project = 'campaignmonitor'
  s.homepage = 'http://github.com/jordanbrock/campaign-monitor-ruby/wikis'

  s.has_rdoc = true
  
  s.requirements << 'none'
  s.require_path = 'lib'

  s.files = $__cm_source_patterns.inject([]) { |list, glob|
  	list << Dir[glob].delete_if { |path|
      File.directory?(path) or
      path.include?('.git/')
    }
  }.flatten

end