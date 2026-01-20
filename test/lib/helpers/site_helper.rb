module SiteHelper
  def set_test_site(code: "test", city: "Test City")
    Upright::Current.site = Upright::Site.new(code: code, city: city)
  end
end
