# encoding: utf-8
require "logstash/outputs/blob/size_rotation_policy"
require "logstash/outputs/blob/time_rotation_policy"

module LogStash
  module Outputs
    class LogstashAzureBlobOutput
      # a sub class of +LogstashAzureBlobOutput+
      # sets the rotation policy 
      class SizeAndTimeRotationPolicy
	# initialize the class
        def initialize(file_size, time_file)
          @size_strategy = SizeRotationPolicy.new(file_size)
          @time_strategy = TimeRotationPolicy.new(time_file)
        end
	# check if it is time to rotate
        def rotate?(file)
          @size_strategy.rotate?(file) || @time_strategy.rotate?(file)
        end
	
 	# boolean method
        def needs_periodic?
          true
        end
      end
    end
  end
end
