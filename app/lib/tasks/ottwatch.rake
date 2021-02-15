namespace :ottwatch do
  desc "Scan all known devapps"
  task scan_dev_apps: :environment do
    DevAppScanner.new.scan_all
  end
end
