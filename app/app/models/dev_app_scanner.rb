require 'csv'

class DevAppScanner
  class DevAppScannerError < StandardError; end
  class DevAppNotFound < DevAppScannerError; end
  class UnexpectedDataCondition < DevAppScannerError; end

  def devapp_xls_data
    uri = URI('https://devapps-restapi.ottawa.ca/devapps/ExportData')
    Net::HTTP.get(uri)
  end

  def convert_xls_to_csv(xls_file, csv_file)
    `ssconvert #{xls_file} #{csv_file} 2>/dev/null`
  end

  def devapp_csv_data(csv_file)
    CSV.parse(File.read(csv_file), headers: true)
  end

  def dev_app_details(devid)
    # query to map from public 'devid' to private '_appid' style.
    url = "https://devapps-restapi.ottawa.ca/devapps/search?authKey=#{authkey}&appStatus=all&searchText=#{devid}&appType=all&ward=all&bounds=0,0,0,0"
    json = Net::HTTP.get(URI(url))
    data = JSON.parse(json)

    raise DevAppNotFound.new(devid) if data['totalDevApps'] == 0
    raise UnexpectedDataCondition.new("Unexpected number of matches for #{devid}") if data['totalDevApps'] > 1

    appid = data['devApps'].first['devAppId']

    # obtain full details on the application
    url = "https://devapps-restapi.ottawa.ca/devapps/#{appid}?authKey=#{authkey}"
    json = Net::HTTP.get(URI(url))
  end

  def ingest_dev_app(devid)
    Rails.logger.info("ingesting #{devid}")
    details = JSON.parse(dev_app_details(devid))

    dev_app = DevApp.find_by(dev_id: devid) || DevApp.new
    dev_app.app_id = details['devAppId']
    dev_app.dev_id = devid
    dev_app.app_type = details['applicationType']['en']
    dev_app.description = details['applicationBriefDesc']['en']
    dev_app.received_on = details['applicationDateYMD']

    DevApp.transaction do
      dev_app.save!

      if dev_details = dev_app.details.last
        if details != dev_details.details
          dev_details = dev_app.details.new
          dev_details.details = details
          dev_details.save!
        end
      else
        dev_details = dev_app.details.new
        dev_details.details = details
        dev_details.save!
      end
    end
  end

  def scan_all
    # get latest XLS data
    Rails.logger.info('downloading xls')
    xls_path = "/tmp/csv_file_#{rand(100_000_000_000)}.xls"
    xls_data = devapp_xls_data
    File.write(xls_path, xls_data.force_encoding(Encoding::UTF_8))

    Rails.logger.info('converting to csv')
    csv_path = "/tmp/csv_file_#{rand(100_000_000_000)}.csv"
    convert_xls_to_csv(xls_path, csv_path)

    Rails.logger.info('scanning')
    csv_data = devapp_csv_data(csv_path)
    csv_data = csv_data.map{ |row| row['Application Number'] }
    csv_data = csv_data.shuffle
    csv_data.each_with_index do |app_id,i|
      begin
        Rails.logger.info("ingesting #{i}/#{csv_data.count} #{app_id}")
        ingest_dev_app(app_id)
      rescue => e
        Rails.logger.error("#{e.class}: #{app_id}: #{e.message}")
        Rails.logger.error(e.backtrace.join("\n"))
      end
    end
  end

  private

  def authkey
    '4r5T2egSmKm5'
  end
end
