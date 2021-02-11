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

  test 'integration test' do
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
end