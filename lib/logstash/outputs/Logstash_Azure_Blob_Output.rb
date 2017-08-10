# encoding: utf-8

require 'logstash/outputs/base'
require 'logstash/namespace'
require 'azure'
require 'pry'

# An Logstash_Azure_Blob_Output output that does nothing.
class LogStash::Outputs::LogstashAzureBlobOutput < LogStash::Outputs::Base
  config_name 'logstash_azure_blob_output'

  public
  def register; end # def register

  public

  def receive(event)

    azure_login
    azure_blob_service = Azure::Blob::BlobService.new
    containers = azure_blob_service.list_containers
    blob = azure_blob_service.create_block_blob(containers[0].name, event.timestamp.to_s, event.to_json)
  end # def event

  private

  def azure_login
    Azure.config.storage_account_name = ENV['AZURE_STORAGE_ACCOUNT']
    Azure.config.storage_access_key = ENV['AZURE_STORAGE_ACCESS_KEY']
  end # def azure_login
end # class LogStash::Outputs::LogstashAzureBlobOutput
