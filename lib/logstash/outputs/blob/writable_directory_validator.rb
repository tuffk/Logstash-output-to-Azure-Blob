module LogStash
  module Outputs
    class LogstashAzureBlobOutput
      # a sub class of +LogstashAzureBlobOutput+
      # validates that the specified tmeporary directory can be accesed with
      # write permission
      class WritableDirectoryValidator
        # Checks if a path is valid
        # @param path [String] String that represents the path
        def self.valid?(path)
          FileUtils.mkdir_p(path) unless Dir.exist?(path)
          ::File.writable?(path)
        rescue
          false
        end
      end
    end
  end
end
