
require 'java'
require 'concurrent'
require 'concurrent/timer_task'
require 'logstash/util'

ConcurrentHashMap = java.util.concurrent.ConcurrentHashMap

module LogStash
  module Outputs
    class LogstashAzureBlobOutput
      # sub class for +LogstashAzureBlobOutput+
      # this class manages the temporary directory for the temporary files
      class FileRepository
        DEFAULT_STATE_SWEEPER_INTERVAL_SECS = 60
        DEFAULT_STALE_TIME_SECS = 15 * 60
        # Ensure that all access or work done
        # on a factory is threadsafe
        class PrefixedValue
          # initialize the factory
          def initialize(file_factory, stale_time)
            @file_factory = file_factory
            @lock = Mutex.new
            @stale_time = stale_time
          end

          # activate the lock
          def with_lock
            @lock.synchronize do
              yield @file_factory
            end
          end

          # boolean method
          def stale?
            with_lock { |factory| factory.current.size.zero? && (Time.now - factory.current.ctime > @stale_time) }
          end

          # return this class
          def apply(_prefix)
            self
          end

          # delete the current factory
          def delete!
            with_lock { |factory| factory.current.delete! }
          end
        end

        # class for initializing the repo manager
        class FactoryInitializer
          # initializes the class
          def initialize(tags, encoding, temporary_directory, stale_time)
            @tags = tags
            @encoding = encoding
            @temporary_directory = temporary_directory
            @stale_time = stale_time
          end

          # applies the prefix key
          def apply(prefix_key)
            PrefixedValue.new(TemporaryFileFactory.new(prefix_key, @tags, @encoding, @temporary_directory), @stale_time)
          end
        end
        # initializes the class with more variables
        def initialize(tags, encoding, temporary_directory,
                       stale_time = DEFAULT_STALE_TIME_SECS,
                       sweeper_interval = DEFAULT_STATE_SWEEPER_INTERVAL_SECS)
          # The path need to contains the prefix so when we start
          # logtash after a crash we keep the remote structure
          @prefixed_factories = ConcurrentHashMap.new

          @sweeper_interval = sweeper_interval

          @factory_initializer = FactoryInitializer.new(tags, encoding, temporary_directory, stale_time)

          start_stale_sweeper
        end

        # gets the key set
        def keys
          @prefixed_factories.keySet
        end

        # with lock for each file
        def each_files
          @prefixed_factories.elements.each do |prefixed_file|
            prefixed_file.with_lock { |factory| yield factory.current }
          end
        end

        # Return the file factory
        def get_factory(prefix_key)
          @prefixed_factories.computeIfAbsent(prefix_key, @factory_initializer).with_lock { |factory| yield factory }
        end

        # gets file from prefix_key
        def get_file(prefix_key)
          get_factory(prefix_key) { |factory| yield factory.current }
        end

        # stops. shutdown
        def shutdown
          stop_stale_sweeper
        end

        # gets factory's size
        def size
          @prefixed_factories.size
        end

        # remove the stale given key and value
        def remove_stale(k, v)
          if v.stale? # rubocop:disable Style/GuardClause
            @prefixed_factories.remove(k, v)
            v.delete!
          end
        end

        # starts the stale sweeper
        def start_stale_sweeper
          @stale_sweeper = Concurrent::TimerTask.new(execution_interval: @sweeper_interval) do
            LogStash::Util.set_thread_name('LogstashAzureBlobOutput, Stale factory sweeper')

            @prefixed_factories.forEach { |k, v| remove_stale(k, v) }
          end

          @stale_sweeper.execute
        end

        # stops the stale sweeper
        def stop_stale_sweeper
          @stale_sweeper.shutdown
        end
      end
    end
  end
end
