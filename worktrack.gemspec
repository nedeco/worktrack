$:.unshift File.expand_path("../lib", __FILE__)

Gem::Specification.new do |gem|
  gem.name        = 'worktrack'
  gem.version     = '0.0.7'
  gem.summary     = "track your work in git repositories"
  gem.description = "worktrack is a gem to monitor your projects directory to track work done within all repos within this directory"
  gem.authors     = ["Alexander Balsam"]
  gem.email       = 'alexander@balsam.de'
  gem.files       = Dir["**/*"].select { |d| d =~ %r{^(README|bin/|data/|ext/|lib/|spec/|test/)} }
  gem.homepage    = "https://github.com/nedeco/worktrack"
  gem.executables = ["worktrack"]
  gem.add_dependency 'listen'
  gem.add_dependency 'sequel'
  gem.add_dependency 'sqlite3'
end