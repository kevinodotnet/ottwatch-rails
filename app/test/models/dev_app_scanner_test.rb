require "test_helper"

require 'rubygems'

require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = "fixtures/vcr_cassettes"
  config.hook_into :webmock
end

class DevAppScannerTest < ActiveSupport::TestCase
  setup do
    @scanner = DevAppScanner.new
  end

  test 'XLS download and parsing integration test' do
    VCR.use_cassette("dev_app_scanner_integration_test") do
      xls_path = "/tmp/csv_file_#{rand(100_000_000_000)}.xls"
      csv_path = "/tmp/csv_file_#{rand(100_000_000_000)}.csv"
      begin
        File.write(xls_path, @scanner.devapp_xls_data.force_encoding(Encoding::UTF_8))
        @scanner.convert_xls_to_csv(xls_path, csv_path)
        result = @scanner.devapp_csv_data(csv_path)
        assert result.is_a?(CSV::Table)

        expected_headers = [
          "Application Number","Application Date","Application Type","Address Number","Road Name",
          "Road Type","Object Status Type","Application Status","File Lead","Brief Description",
          "Object Status Date","Ward #","Ward"
        ]
        assert_equal expected_headers.sort, result.first.headers.sort
      ensure
        File.delete(xls_path)
        File.delete(csv_path)
      end
    end
  end

  test '#dev_app_details obtains details on the provided devapp' do
    VCR.use_cassette("dev_app_scanner_dev_app_details") do
      expected_keys = [
        "devAppId",
       "applicationNumber",
       "applicationDate",
       "applicationDateYMD",
       "applicationTypeId",
       "applicationType",
       "applicationBriefDesc",
       "applicationStatus",
       "devAppAddresses",
       "devAppDocuments",
       "objectStatus",
       "devAppWard",
       "endOfCirculationDate",
       "endOfCirculationDateYMD",
       "canComment",
       "showFeedbackLink",
       "plannerFirstName",
       "plannerLastName",
       "plannerPhone",
       "plannerEmail",
       "searchableText"
      ].sort
      details = @scanner.dev_app_details('D07-12-16-0093')
      assert_equal expected_keys, details.keys.sort
    end
  end
end