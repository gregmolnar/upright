module IpApiHelper
  def stub_ip_api_batch(response_body = "[]")
    stub_request(:post, "http://ip-api.com/batch").to_return(status: 200, body: response_body)
  end
end
