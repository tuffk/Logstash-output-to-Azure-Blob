# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/outputs/Logstash_Azure_Blob_Output"
require "logstash/codecs/plain"
require "logstash/event"
require 'pry'

describe LogStash::Outputs::LogstashAzureBlobOutput do
  let(:sample_event) { LogStash::Event.new({source: "alguna", tags: ["tag1", "tag2"], fields: {field1: 1, field2: true}}) }
  let(:output) { LogStash::Outputs::LogstashAzureBlobOutput.new }

  before do
    output.register
  end

  describe "receive message" do
    subject { output.receive(sample_event) }
    it "should return the blob sent to Azure" do
      md5 = Digest::MD5.base64digest(sample_event.to_json)
      expect(subject.properties[:content_md5]).to eq(md5)
    end
  end
end
