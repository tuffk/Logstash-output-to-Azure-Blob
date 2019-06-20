Gem::Specification.new do |s|
  s.name          = 'logstash-output-azure'
  s.version       = '2.1.0'
  s.licenses      = ['Apache-2.0']
  s.summary       = 'Plugin for logstash to send output to Microsoft Azure Blob'
  # s.description   = 'TODO: Write a longer description or delete this line.'
  # s.homepage      = 'TODO: Put your plugin''s website or public repo URL here.'
  s.authors       = ['Tuffk']
  s.email         = 'tuffkmulhall@gmail.com'
  s.require_paths = ['lib']

  # Files
  s.files = Dir['lib/**/*', 'spec/**/*', 'vendor/**/*', '*.gemspec', '*.md', 'CONTRIBUTORS', 'Gemfile', 'LICENSE', 'NOTICE.TXT']
  # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { 'logstash_plugin' => 'true', 'logstash_group' => 'output' }

  # Gem dependencies
  s.add_runtime_dependency 'azure', '~> 0.7'
  s.add_runtime_dependency 'logstash-codec-plain'
  s.add_runtime_dependency 'logstash-core-plugin-api', '~> 2.1'
  s.add_development_dependency 'logstash-devutils'
end
