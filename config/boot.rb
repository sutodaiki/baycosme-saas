ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

# Fix for Ruby 2.6 compatibility
require 'logger'

begin
  require 'bundler/setup' # Set up gems listed in the Gemfile.
rescue LoadError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end