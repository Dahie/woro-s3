require 'spec_helper'

describe Woro::Adapters::S3 do

  let(:task) { Woro::Task.new('create_user') }
  subject do
    options = { bucket_name: 's3-bucket', folder_name: 'snippets/' }
    Woro::Adapters::S3.new(options)
  end

  before do
    FakeFS.deactivate!
    allow(subject).to receive(:get_object).once.and_return 'https://gist.githubusercontent.com/raw/365370/8c4d2d43d178df44f4c03a7f2ac0ff512853564e/ring.erl'
  end

  after do
    FakeFS.activate!
  end

  describe '#list_files' do
    it 'returns list' do
      expect(subject.list_files).to eq ["create_user.rake"]
    end
  end

  describe '#push' do
    it 'calls s3 services with correct params' do
      File.open(task.file_path, 'w') do |f|
        f.puts 'hey'
      end
      expected_hash = {
        bucket_name: 's3-bucket',
        prefix: 'snippets/',
        key: key, data: task.file_name
      }
      expect(AWS::S3::Client).to receive(:put_object).with(expected_hash).and_return true
      subject.push(task)
    end
  end

  describe '#retrieve_file_data' do
    it 'returns data hash from file' do
      expected_hash = {
        "size"=>932, "raw_url"=>"https://gist.githubusercontent.com/raw/365370/8c4d2d43d178df44f4c03a7f2ac0ff512853564e/ring.erl", "type"=>"text/plain", "language"=>"Ruby", "truncated"=>false, "content"=>"namespace :woro do\n  desc 'Create User'\n  task create_user: :environment do\n    # Code\n  end\nend\n"
      }
      expect(subject.send(:retrieve_file_data, 'create_user.rake')).to eq expected_hash
    end
  end

  describe '#raw_url' do
    it 'returns raw_url of file' do
      expected_url = "https://gist.githubusercontent.com/raw/365370/8c4d2d43d178df44f4c03a7f2ac0ff512853564e/ring.erl"
      expect(subject.raw_url('create_user.rake')).to eq expected_url
    end
  end
end
