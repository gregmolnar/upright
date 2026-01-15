module SiteHelper
  def with_test_site(code: "test", city: "Test City")
    Upright::Current.site = Upright::Site.new(code: code, city: city)
    yield
  ensure
    Upright::Current.site = nil
  end

  def set_test_site(code: "test", city: "Test City")
    Upright::Current.site = Upright::Site.new(code: code, city: city)
  end
end
