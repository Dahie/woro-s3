require 'aws-sdk-v1'

module Woro
  module Adapters
    # Adapter for managing remote task collection on AWS S3
    class S3 < Base
      # serialized configuration for AWS S3 access
      attr_reader :s3_client, :bucket_name, :path

      # Setup configuration for adapter
      # Highline CLI helpers can be used for interactivity.
      # @return [Hash] Configuration options
      def self.setup
        {
          'access_key_id' =>     ask('Access key id: '),
          'secret_access_key' => ask('Secret access key: '),
          'region' =>            ask('Region: ') { |q| q.default = 'eu-west-1' },
          'bucket_name' =>       ask('Bucket name: '),
          'path' =>              ask('Path within Bucket: ') { |q| q.default = '/' },
        }
      end

      def initialize(options)
        options.reject! { |k, v| [:path].include? k }
        ::AWS.config options
        @s3_client = ::AWS::S3::Client.new options
        @bucket_name = options['bucket_name']
        @path = options['path']
      end

      # Returns the list of rake files included in the remote collection.
      # @return [Array] List of files
      def list_files
        remote_files
      end

      # Returns the list of rake files included in the remote collection
      # with their contents.
      # @return [Hash] List of files with their contents
      def list_contents
        {}.tap do |files|
          remote_files do |file_name|
            resp = get_object(file_name)
            files[file_name] = { data: resp }
          end
        end
      end

      def list_keys_in(path)
        [].tap do |keys|
          list_objects(path)[:contents].each do |s3_object|
            keys << s3_object[:key]
          end
        end
      end

      # Push this task's file content to S3 server.
      # Existing contents by the same #file_name will be overriden.
      def push(task)
        create_object(task.file_name, task.read_task_file).inspect
        { 'url' => "s3://#{bucket_name}#{path}#{task.file_name}" }
      end

      # The raw url is a permalink for downloading the content rake task within
      # the Gist as a file.
      # @param file_name [String] name of the file to retrieve the download url
      # @return [String] HTTP-URL of addressed file within the gist collection
      def raw_url(file_name)
        bucket = AWS::S3::Bucket.new(bucket_name)
        object = AWS::S3::S3Object.new(bucket, "#{path}#{file_name}")
        object.url_for(:read)
      end

      protected

      def remote_files
        [].tap do |keys|
          list_objects(path)[:contents].each do |s3_object|
            file_name = s3_object[:key] if s3_object[:key].include?('.rake')
            if file_name
              keys << file_name.split('/').last
              yield file_name.split('/').last
            end
          end
        end
      end

      def create_object_unless_present(key, data)
        create_object(key, data) if list_keys_in(key).empty?
      end

      def get_object(key)
        s3_client.get_object(bucket_name: bucket_name,
                             key: key)[:data]
      end

      def list_objects(prefix = nil)
        s3_client.list_objects(bucket_name: bucket_name,
                               prefix: prefix)
      end

      def create_object(key, data)
        s3_client.put_object(bucket_name: bucket_name,
                             key: "#{path}#{key}",
                             data: data)
      end

      def retrieve_file_data(file_name)
        get_object(file_name)
      end

      def delete_object(key)
        s3_client.delete_object(bucket_name: bucket_name, key: key)
      end
    end
  end
end
