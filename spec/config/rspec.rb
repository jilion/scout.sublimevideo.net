RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run_including focus: ENV['CI'] != 'true'
  config.mock_with :rspec
  config.fail_fast = ENV['CI'] != 'true'
  config.order = ENV['ORDER'] || 'random'
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
