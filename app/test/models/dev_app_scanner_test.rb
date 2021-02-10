require "test_helper"

class DevAppScannerTest < ActiveSupport::TestCase
  setup do
    @scanner = DevAppScanner.new
  end

  test '#devapp_xls_data returns binary XLS payload' do
    xls_data = @scanner.devapp_xls_data
    assert xls_data.is_a?(String)
    assert xls_data.length > 10_000 # this big, it's probably good Excel data.
  end
end