# encoding: utf-8

require 'logstash/devutils/rspec/spec_helper'
require 'logstash/outputs/azure'
require 'logstash/codecs/plain'
require 'logstash/event'
require 'tmpdir'
require 'pry'

describe LogStash::Outputs::LogstashAzureBlobOutput do
  let(:config_options) do
    {
      storage_account_name: ENV['AZURE_STORAGE_ACCOUNT'],
      storage_access_key: ENV['AZURE_STORAGE_ACCESS_KEY'],
      container_name: "test",
      size_file: 5242880,
      time_file: 15,
      restore: true,
      temporary_directory: File.join(Dir.tmpdir, 'logstash'),
      prefix: '',
      upload_queue_size: 2 * (Concurrent.processor_count * 0.25).ceil,
      upload_workers_count: (Concurrent.processor_count * 0.5).ceil,
      rotation_strategy: 'size_and_time',
      tags: [],
      encoding: "none"
    }
  end
  let(:sample_event) { LogStash::Event.new(source: 'alguna', tags: %w[tag1 tag2], fields: { field1: 1, field2: true }) }

  # let(:output) { described_class.new() }
  #
  # before do
  #   output.register
  # end

  it 'should create' do
    blober = described_class.new
    blober.register
    expect(blober.storage_account_name).not_to be_nil
    expect(blober.storage_access_key).not_to be_nil
    expect(blober.container_name).not_to be_nil
  end

  describe 'receive message' do
    subject { output.receive(sample_event) }
    xit 'should return the blob sent to Azure' do
      md5 = Digest::MD5.base64digest(sample_event.to_json)
      expect(subject.properties[:content_md5]).to eq(md5)
    end
  end
end
