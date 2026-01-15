class Upright::Current < ActiveSupport::CurrentAttributes
  attribute :user
  attribute :subdomain
  attribute :site

  def site
    super || Upright.current_site
  end
end
