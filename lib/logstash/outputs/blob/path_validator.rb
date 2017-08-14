# encoding: utf-8
module LogStash
  module Outputs
    class LogstashAzureBlobOutput
      # a sub class of +LogstashAzureBlobOutput+
      # valdiates the path for the temporary directory
      class PathValidator
        INVALID_CHARACTERS = "\^`><"

        def self.valid?(name)
          name.match(matches_re).nil?
        end

        def self.matches_re
          /[#{Regexp.escape(INVALID_CHARACTERS)}]/
        end
      end
    end
  end
end
