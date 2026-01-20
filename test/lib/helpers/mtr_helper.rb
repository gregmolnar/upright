module MtrHelper
  def stub_mtr_with_fixture(result, fixture_name)
    result.stubs(:run_mtr).returns(file_fixture("#{fixture_name}.json").read)
    stub_ip_api_batch
    result.run
  end
end
