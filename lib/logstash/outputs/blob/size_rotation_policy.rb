module LogStash
  module Outputs
    class LogstashAzureBlobOutput
      # a sub class of +LogstashAzureBlobOutput+
      # sets the rotation policy by size
      class SizeRotationPolicy
        attr_reader :size_file
        # initialize the class
        def initialize(size_file)
          if size_file <= 0
            raise LogStash::ConfigurationError.new('`size_file` need to be greather than 0')
          end

          @size_file = size_file
        end

        # boolean method to check if it is time to rotate
        def rotate?(file)
          file.size >= size_file
        end

        # boolean method
        def needs_periodic?
          false
        end
      end
    end
  end
end
