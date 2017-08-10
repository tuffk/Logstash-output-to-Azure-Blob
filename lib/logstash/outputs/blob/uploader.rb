# encoding: utf-8
require "logstash/util"
require "azure"

module LogStash
  module Outputs
    class LogstashAzureBlobOutput
      class Uploader
        TIME_BEFORE_RETRYING_SECONDS = 1
        DEFAULT_THREADPOOL = Concurrent::ThreadPoolExecutor.new({
                                                                  :min_threads => 1,
                                                                  :max_threads => 8,
                                                                  :max_queue => 1,
                                                                  :fallback_policy => :caller_runs
                                                                })


        attr_reader :storage_account_name, :upload_options, :logger

        def initialize(blob_account, logger, threadpool = DEFAULT_THREADPOOL)
          @blob_account = blob_account
          @workers_pool = threadpool
          @logger = logger
        end

        def upload_async(file, options = {})
          @workers_pool.post do
            LogStash::Util.set_thread_name("LogstashAzureBlobOutput output uploader, file: #{file.path}")
            upload(file, options)
          end
        end

        def upload(file, options = {})
          upload_options = options.fetch(:upload_options, {})

          begin
            Azure.config.storage_account_name = ENV['AZURE_STORAGE_ACCOUNT']
            Azure.config.storage_access_key = ENV['AZURE_STORAGE_ACCESS_KEY']
            azure_blob_service = Azure::Blob::BlobService.new
            containers = azure_blob_service.list_containers
            blob = azure_blob_service.create_block_blob(containers[0].name, event.timestamp.to_s, event.to_json)
          rescue => e
            # When we get here it usually mean that LogstashAzureBlobOutput tried to do some retry by himself (default is 3)
            # When the retry limit is reached or another error happen we will wait and retry.
            #
            # Thread might be stuck here, but I think its better than losing anything
            # its either a transient errors or something bad really happened.
            logger.error("Uploading failed, retrying", :exception => e.class, :message => e.message, :path => file.path, :backtrace => e.backtrace)
            retry
          end

          options[:on_complete].call(file) unless options[:on_complete].nil?
        rescue => e
          logger.error("An error occured in the `on_complete` uploader", :exception => e.class, :message => e.message, :path => file.path, :backtrace => e.backtrace)
          raise e # reraise it since we don't deal with it now
        end

        def stop
          @workers_pool.shutdown
          @workers_pool.wait_for_termination(nil) # block until its done
        end
      end
    end
  end
end
