$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'db_schema'
require 'db_schema/reader/postgres'
require 'pry'
require 'awesome_print'
AwesomePrint.pry!

require_relative './support/db_cleaner'

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.disable_monkey_patching!

  config.profile_examples = 10

  config.include DbCleaner

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
