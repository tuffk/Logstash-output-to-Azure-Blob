# encoding: utf-8
shared_context "setup plugin" do
  let(:temporary_directory) { Stud::Temporary.pathname }
  let(:storage_account_name) { ENV["AZURE_STORAGE_ACCOUNT"] }
  let(:storage_access_key) {  ENV["AZURE_STORAGE_ACCESS_KEY"] }
  let(:size_file) { 100 }
  let(:time_file) { 100 }
  let(:tags) { [] }
  let(:prefix) { "home" }

  let(:main_options) do
    {
      "storage_account_name" => bucket,
      "prefix" => prefix,
      "temporary_directory" => temporary_directory,
      "storage_access_key" => access_key_id,
      "size_file" => size_file,
      "time_file" => time_file,
      "tags" => []
    }
  end

  subject { LogStash::Outputs::LogstashAzureBlobOutput.new(options) }
end

def clean_remote_files(prefix = "")
  bucket_resource.objects(:prefix => prefix).each do |object|
    object.delete
  end
end
