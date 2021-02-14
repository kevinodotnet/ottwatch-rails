require 'csv'

class DevAppScanner
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

    appid = data['devApps'].first['devAppId']

    # obtain full details on the application
    url = "https://devapps-restapi.ottawa.ca/devapps/#{appid}?authKey=#{authkey}"
    json = Net::HTTP.get(URI(url))
  end

  def injest_dev_app(devid)
    details = JSON.parse(dev_app_details(devid))

    dev_app = DevApp.find_by(dev_id: devid) || DevApp.new
    dev_app.app_id = details['devAppId']
    dev_app.dev_id = devid
    dev_app.app_type = details['applicationType']['en']
    dev_app.description = details['applicationBriefDesc']['en']
    dev_app.received_on = details['applicationDateYMD']
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

  private

  def authkey
    '4r5T2egSmKm5'
  end

  # def scan
  #   #process_devapp('D07-12-16-0093')
  #   process_devapp('D02-02-20-0110')
  #   return
  #   devapp_csv_data.each do |row|
  #     process_devapp(row['Application Number'])
  #   end
  # end
end
