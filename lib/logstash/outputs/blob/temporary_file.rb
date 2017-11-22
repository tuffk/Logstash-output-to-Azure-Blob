require 'thread'
require 'forwardable'
require 'fileutils'

module LogStash
  module Outputs
    class LogstashAzureBlobOutput
      # a sub class of +LogstashAzureBlobOutput+
      # Wrap the actual file descriptor into an utility classe
      # It make it more OOP and easier to reason with the paths.
      class TemporaryFile
        extend Forwardable

        def_delegators :@fd, :path, :write, :close, :fsync

        attr_reader :fd

        # initialize the class
        def initialize(key, fd, temp_path)
          @fd = fd
          @key = key
          @temp_path = temp_path
          @created_at = Time.now
        end

        # gets the created at time
        def ctime
          @created_at
        end

        # gets path to temporary directory
        attr_reader :temp_path

        # gets the size of file
        def size
          # Use the fd size to get the accurate result,
          # so we dont have to deal with fsync
          # if the file is close we will use the File::size

          @fd.size
        rescue IOError
          ::File.size(path)
        end

        # gets the key
        def key
          @key.gsub(/^\//, '')
        end

        # Each temporary file is made inside a directory named with an UUID,
        # instead of deleting the file directly and having the risk of deleting other files
        # we delete the root of the UUID, using a UUID also remove the risk of deleting unwanted file, it acts as
        # a sandbox.
        def delete!
          begin
            @fd.close
          rescue
            IOError
          end
          FileUtils.rm_r(@temp_path, secure: true)
        end

        # boolean method to determine if the file is empty
        def empty?
          size.zero?
        end

        # creates the temporary file in an existing temporary directory from existing file
        # @param file_path [String] path to the file
        # @param temporary_folder [String] path to the temporary folder
        def self.create_from_existing_file(file_path, temporary_folder)
          key_parts = Pathname.new(file_path).relative_path_from(temporary_folder).to_s.split(::File::SEPARATOR)

          TemporaryFile.new(key_parts.slice(1, key_parts.size).join('/'),
                            ::File.open(file_path, 'r'),
                            ::File.join(temporary_folder, key_parts.slice(0, 1)))
        end
      end
    end
  end
end
