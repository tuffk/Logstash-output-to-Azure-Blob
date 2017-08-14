# encoding: utf-8
module LogStash
  module Outputs
    class LogstashAzureBlobOutput
      # a sub class of +LogstashAzureBlobOutput+
      # validates that the specified tmeporary directory can be accesed with
      # write permission
      class WritableDirectoryValidator
        def self.valid?(path)
          begin
            FileUtils.mkdir_p(path) unless Dir.exist?(path)
            ::File.writable?(path)
          rescue
            false
          end
        end
      end
    end
  end
end
