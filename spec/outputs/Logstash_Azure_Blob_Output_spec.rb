# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/outputs/Logstash_Azure_Blob_Output"
require "logstash/codecs/plain"
require "logstash/event"
require 'pry'

describe LogStash::Outputs::LogstashAzureBlobOutput do
  let(:sample_event) { LogStash::Event.new }
  let(:output) { LogStash::Outputs::LogstashAzureBlobOutput.new }

  before do
    output.register
  end

  describe "receive message" do
    subject { output.receive(sample_event) }
    it "returns a string" do
      expect(subject).to eq("Event received")
    end
  end
end
