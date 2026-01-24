module Upright::ApplicationHelper
  def current_or_default_site
    Upright::Current.site || Upright.sites.first
  end

  def upright_stylesheet_link_tag(**options)
    Upright::Engine.root.join("app/assets/stylesheets/upright").glob("*.css")
      .map { |f| "upright/#{f.basename('.css')}" }.sort
      .then { |stylesheets| stylesheet_link_tag(*stylesheets, **options) }
  end
end
