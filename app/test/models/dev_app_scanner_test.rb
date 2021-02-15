require "test_helper"
require 'rubygems'
require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = "fixtures/vcr_cassettes"
  config.hook_into :webmock
end

class DevAppScannerTest < ActiveSupport::TestCase
  DEV_APP_ID = 'D07-12-16-0093'
  DEV_APP_DETAILS_EXPECTED_KEYS = [
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


  setup do
    @scanner = DevAppScanner.new
  end

  test 'XLS download and parsing integration test' do
    VCR.use_cassette("#{class_name}_#{method_name}") do
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
    VCR.use_cassette("#{class_name}_#{method_name}") do
      details = @scanner.dev_app_details(DEV_APP_ID)
      assert_equal DEV_APP_DETAILS_EXPECTED_KEYS, JSON.parse(details).keys.sort
    end
  end

  test '#ingest_dev_app creates DevApp & DevAppStatus records when new devapp is ingested' do
    VCR.use_cassette("#{class_name}_#{method_name}") do
      assert_changes -> { DevAppDetail.count } do
        assert_changes -> { DevApp.count } do
          @scanner.ingest_dev_app(DEV_APP_ID)
        end
      end


      dev_app = DevApp.find_by(dev_id: DEV_APP_ID)
      assert dev_app

      assert_equal "__003SPU", dev_app[:app_id]
      assert_equal "D07-12-16-0093", dev_app[:dev_id]
      assert_equal "Site Plan Control", dev_app[:app_type]
      assert_equal "New 16 unit building for affordable rental housing", dev_app[:description]
      assert_equal "2016-06-28".to_date, dev_app[:received_on]
      assert_equal DEV_APP_DETAILS_EXPECTED_KEYS, dev_app.latest_details.keys.sort
    end
  end

  test '#ingest_dev_app detects and persists updated details' do
    VCR.use_cassette("#{class_name}_#{method_name}") do
      @scanner.ingest_dev_app(DEV_APP_ID)

      dev_app = DevApp.find_by(dev_id: DEV_APP_ID)
      details = dev_app.details.last
      details.details["applicationStatus"]['en'] = 'Foo'
      details.save!

      assert_changes -> { DevAppDetail.count } do
        @scanner.ingest_dev_app(DEV_APP_ID)
      end

      assert_equal 2, dev_app.reload.details.count
    end
  end

  test '#dev_app_details raises DevAppNotFound if the devapp does not exist' do
    VCR.use_cassette("#{class_name}_#{method_name}") do
      assert_raises DevAppScanner::DevAppNotFound do
        @scanner.dev_app_details("fake_kevino")
      end
    end
  end

  test '#dev_app_details raises UnexpectedDataCondition if a query for devapp details returns multiple records' do
    fake_response = {
      totalDevApps: 2
    }
    Net::HTTP.expects(:get).returns(fake_response.to_json)
    assert_raises DevAppScanner::UnexpectedDataCondition do
      @scanner.dev_app_details('fake_irrelavent_value')
    end
  end

  test '#scan_all uses CSV payload then calls ingest_dev_app for each row' do
    d1 = rand(100_000_000).to_s
    d2 = rand(100_000_000).to_s
    fake_records = [
      { 'Application Number' => d1 },
      { 'Application Number' => d2 },
    ]
    DevAppScanner.any_instance.expects(:devapp_xls_data).returns('fake') # avoid HTTP call inside test
    DevAppScanner.any_instance.expects(:devapp_csv_data).returns(fake_records)
    DevAppScanner.any_instance.expects(:ingest_dev_app).with(d1).times(1)
    DevAppScanner.any_instance.expects(:ingest_dev_app).with(d2).times(1)
    @scanner.scan_all
  end
end