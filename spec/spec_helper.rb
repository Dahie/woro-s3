require 'woro'
require 'woro-s3'
require 'fakefs/safe'
require 'aws-sdk-v1'

Dir[('./spec/support/**/*.rb')].each {|f| require f}

RSpec.configure do |config|
  config.color = true
  config.order = 'random'

  config.before(:each) do
    FakeFS.activate!
    FileUtils.mkdir_p 'config'
    FileUtils.mkdir_p 'lib/woro_tasks'
    FileUtils.mkdir_p 'lib/tasks'
  end
end
