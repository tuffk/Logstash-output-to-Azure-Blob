# encoding: utf-8
require "logstash/outputs/base"
require "logstash/namespace"

# An Logstash_Azure_Blob_Output output that does nothing.
class LogStash::Outputs::LogstashAzureBlobOutput < LogStash::Outputs::Base
  config_name "Logstash_Azure_Blob_Output"

  public
  def register
  end # def register

  public
  def receive(event)
    return "Event received"
  end # def event
end # class LogStash::Outputs::LogstashAzureBlobOutput
