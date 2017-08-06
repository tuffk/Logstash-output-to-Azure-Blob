# encoding: utf-8

require 'logstash/outputs/base'
require 'logstash/namespace'
require 'azure'

# An Logstash_Azure_Blob_Output output that does nothing.
class LogStash::Outputs::LogstashAzureBlobOutput < LogStash::Outputs::Base
  config_name 'Logstash_Azure_Blob_Output'
  ENV['AZURE_STORAGE_ACCOUNT'] ||= 'algo'
  ENV['AZURE_STORAGE_ACCESS_KEY'] ||= 'algomas'
  Azure.config.storage_account_name = ENV['AZURE_STORAGE_ACCOUNT']
  Azure.config.storage_access_key = ENV['AZURE_STORAGE_ACCESS_KEY']

  public

  def register; end # def register

  public

  def receive(event)
    azure_blob_service = Azure::Blob::BlobService.new
    container = azure_blob_service.list_contianers # FIXME: get only one container
    blob = azure_blob_service.create_block_blob(container.name, "name #{event.name}", event.content )

    'Event received'
  end # def event
end # class LogStash::Outputs::LogstashAzureBlobOutput
