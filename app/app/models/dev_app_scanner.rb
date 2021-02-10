class DevAppScanner

  def devapp_xls_data
    uri = URI('https://devapps-restapi.ottawa.ca/devapps/ExportData')
    Net::HTTP.get(uri)
  end

  # def authkey
  #   '4r5T2egSmKm5'
  # end

  # def devapp_csv_data
  #   uri = URI('https://devapps-restapi.ottawa.ca/devapps/ExportData')
  #   csv_file = '/tmp/devapp.csv'
  #   xls_file = '/tmp/devapp.xlsx'
  #   # File.write('/tmp/devapp.xlsx', Net::HTTP.get(uri))
  #   `ssconvert #{xls_file} #{csv_file} 2>/dev/null`
  #   CSV.parse(File.read(csv_file), headers: true)
  # end

  # def process_devapp(devid)
  #   url = "https://devapps-restapi.ottawa.ca/devapps/search?authKey=#{authkey}&appStatus=all&searchText=#{devid}&appType=all&ward=all&bounds=0,0,0,0"
  #   json = Net::HTTP.get(URI(url))
  #   data = JSON.parse(json)

  #   appid = data['devApps'].first['devAppId']

  #   url = "https://devapps-restapi.ottawa.ca/devapps/#{appid}?authKey=#{authkey}"
  #   json = Net::HTTP.get(URI(url))
  #   data2 = JSON.parse(json)

  #   devapp = DevApp.find_by(devid: devid)

  #   devapp.address = data2['devAppAddresses'].map{|a| {lat: a['addressLatitude'], lon: a['addressLongitude'], addr: a['addressNumberRoadName']}}.to_json
  #   devapp.apptype = data2.dig('applicationType', 'en')
  #   devapp.receiveddate = data2['applicationDateYMD']

  #   ward = data2['devAppWard']
  #   devapp.ward = "#{ward.dig('wardNumber', 'en')} - #{ward.dig('wardName', 'en')} - #{ward['councillorFirstName']} #{ward['councillorLastName']}"

  #   binding.pry

  #   1
  # end

  # def scan
  #   #process_devapp('D07-12-16-0093')
  #   process_devapp('D02-02-20-0110')
  #   return
  #   devapp_csv_data.each do |row|
  #     process_devapp(row['Application Number'])
  #   end
  # end
end
