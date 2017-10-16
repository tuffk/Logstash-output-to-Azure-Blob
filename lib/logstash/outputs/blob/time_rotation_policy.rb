# encoding: utf-8
module LogStash
  module Outputs
    class LogstashAzureBlobOutput
      # a sub class of +LogstashAzureBlobOutput+
      # sets the policy for time rotation
      class TimeRotationPolicy
        attr_reader :time_file
        # initialize the class and validate the time file
        def initialize(time_file)
          if time_file <= 0
            raise LogStash::ConfigurationError, "`time_file` need to be greather than 0"
          end

          @time_file = time_file * 60
        end

	# rotates based on time policy
        def rotate?(file)
          file.size > 0 && (Time.now - file.ctime) >= time_file
        end
	
	# boolean method
        def needs_periodic?
          true
        end
      end
    end
  end
end
