require 'socket'
require 'securerandom'
require 'fileutils'
require 'zlib'
require 'forwardable'

module LogStash
  module Outputs
    class LogstashAzureBlobOutput
      # a sub class of +LogstashAzureBlobOutput+
      # creates the temporary files to write and later upload
      class TemporaryFileFactory
        FILE_MODE = 'a'.freeze
        GZIP_ENCODING = 'gzip'.freeze
        GZIP_EXTENSION = 'txt.gz'.freeze
        TXT_EXTENSION = 'txt'.freeze
        STRFTIME = '%Y-%m-%dT%H.%M'.freeze

        attr_accessor :counter, :tags, :prefix, :encoding, :temporary_directory, :current

        # initialize the class
        def initialize(prefix, tags, encoding, temporary_directory)
          @counter = 0
          @prefix = prefix

          @tags = tags
          @encoding = encoding
          @temporary_directory = temporary_directory
          @lock = Mutex.new

          rotate!
        end

        # do the rotation
        def rotate!
          @lock.synchronize do
            @current = new_file
            increment_counter
            @current
          end
        end

        private

        # if it is not gzip ecoding, then it is txt extension
        def extension
          gzip? ? GZIP_EXTENSION : TXT_EXTENSION
        end

        # boolean method to check if its gzip encoding
        def gzip?
          encoding == GZIP_ENCODING
        end

        # increment the counter in 1 unit
        def increment_counter
          @counter += 1
        end

        # gets the current time
        def current_time
          Time.now.strftime(STRFTIME)
        end

        # method that generate the name of the file to be saved in blob storage
        def generate_name
          filename = "#{current_time}.#{SecureRandom.uuid}"

          if !tags.empty?
            "#{filename}.tag_#{tags.join('.')}.part#{counter}.#{extension}"
          else
            "#{filename}.part#{counter}.#{extension}"
          end
        end

        # create the file to be saved in blob storage
        def new_file
          uuid = SecureRandom.uuid
          name = generate_name
          path = ::File.join(temporary_directory, uuid)
          key = ::File.join(prefix, name)

          FileUtils.mkdir_p(::File.join(path, prefix))

          io = if gzip?
                 # We have to use this wrapper because we cannot access the size of the
                 # file directly on the gzip writer.
                 IOWrappedGzip.new(::File.open(::File.join(path, key), FILE_MODE))
               else
                 ::File.open(::File.join(path, key), FILE_MODE)
               end

          TemporaryFile.new(key, io, path)
        end

        # clas for the encoding
        class IOWrappedGzip
          extend Forwardable

          def_delegators :@gzip_writer, :write, :close
          attr_reader :file_io, :gzip_writer

          # initialize the class for encoding
          def initialize(file_io)
            @file_io = file_io
            @gzip_writer = Zlib::GzipWriter.open(file_io)
          end

          # gets the path
          def path
            @gzip_writer.to_io.path
          end

          # gets the file size
          def size
            # to get the current file size
            if @gzip_writer.pos.zero?
              # Ensure a zero file size is returned when nothing has
              # yet been written to the gzip file.
              0
            else
              @gzip_writer.flush
              @gzip_writer.to_io.size
            end
          end

          # gets the fsync
          def fsync
            @gzip_writer.to_io.fsync
          end
        end
      end
    end
  end
end
