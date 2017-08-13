# encoding: utf-8

require 'logstash/devutils/rspec/spec_helper'
require 'logstash/outputs/Logstash_Azure_Blob_Output'
require 'logstash/codecs/plain'
require 'logstash/event'
require 'tmpdir'
require 'pry'

describe LogStash::Outputs::LogstashAzureBlobOutput do
  let(:config_options) do
    {
      storage_account_name: ENV['AZURE_STORAGE_ACCOUNT'],
      storage_access_key: ENV['AZURE_STORAGE_ACCESS_KEY'],
      size_file: 5_242_880,
      time_file: 15,
      restore: true,
      temporary_directory: File.join(Dir.tmpdir, 'logstash'),
      prefix: '',
      upload_queue_size: 2 * (Concurrent.processor_count * 0.25).ceil,
      upload_workers_count: (Concurrent.processor_count * 0.5).ceil,
      rotation_strategy: 'size_and_time'
    }
  end
  let(:sample_event) { LogStash::Event.new(source: 'alguna', tags: %w[tag1 tag2], fields: { field1: 1, field2: true }) }

  let(:output) { described_class.new() }

  before do
    output.register
  end

  describe 'receive message' do
    subject { output.receive(sample_event) }
    it 'should return the blob sent to Azure' do
      md5 = Digest::MD5.base64digest(sample_event.to_json)
      expect(subject.properties[:content_md5]).to eq(md5)
    end
  end
end
