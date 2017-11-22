require 'logstash/devutils/rspec/spec_helper'
require 'logstash/outputs/blob/uploader'
require 'logstash/outputs/blob/temporary_file'
require 'azure'
require 'stud/temporary'

describe LogStash::Outputs::LogstashAzureBlobOutput::Uploader do
  let(:logger) { spy(:logger) }
  let(:max_upload_workers) { 1 }
  let(:storage_account_name) { 'test-cointainer' }
  let(:temporary_directory) { Stud::Temporary.pathname }
  let(:temporary_file) { Stud::Temporary.file }
  let(:storage_access_key) { 'foobar' }
  let(:upload_options) { {} }
  let(:threadpool) do
    Concurrent::ThreadPoolExecutor.new(min_threads: 1,
                                       max_threads: 8,
                                       max_queue: 1,
                                       fallback_policy: :caller_runs)
  end

  let(:file) do
    f = LogStash::Outputs::LogstashAzureBlobOutput::TemporaryFile.new(storage_access_key, temporary_file, temporary_directory)
    f.write('random content')
    f.fsync
    f
  end

  # subject { described_class.new(storage_account_name, logger, threadpool) }

  # it "upload file to the blob" do
  #  expect { subject.upload(file) }.not_to raise_error
  # end

  # it "execute a callback when the upload is complete" do
  #  callback = proc { |f| }

  #  expect(callback).to receive(:call).with(file)
  #  subject.upload(file, { :on_complete => callback })
  # end

  # it 'the content in the blob and sent should be equal' do
  #  blob = subject.upload(file)
  #  md5 = Digest::MD5.base64digest(Object::File.open(file.path).read)
  #  expect(blob.properties[:content_md5]).to eq(md5)
  # end

  #  xit "retries errors indefinitively" do
  #    blob = double("blob").as_null_object

  #    expect(logger).to receive(:error).with(any_args).once

  #    expect(storage_account_name).to receive(:object).with(file.key).and_return(blob).twice

  #    expect(blob).to receive(:upload_file).with(any_args).and_raise(StandardError)

  #    expect(blob).to receive(:upload_file).with(any_args).and_return(true)

  #    subject.upload(file)
  #  end
end
