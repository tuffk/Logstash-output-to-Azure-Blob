module LogStash
  module Outputs
    class LogstashAzureBlobOutput
      # a sub class of +LogstashAzureBlobOutput+
      # valdiates the path for the temporary directory
      class PathValidator
        INVALID_CHARACTERS = "\^`><".freeze
        # boolean method to check if a name is valid
        def self.valid?(name)
          name.match(matches_re).nil?
        end

        # define the invalid characters that shouldn't be in the path name
        def self.matches_re
          /[#{Regexp.escape(INVALID_CHARACTERS)}]/
        end
      end
    end
  end
end
