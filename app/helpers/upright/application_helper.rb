module Upright::ApplicationHelper
  def current_or_default_site
    Upright::Current.site || Upright.sites.first
  end

  def upright_stylesheet_link_tag(**options)
    stylesheets = Dir[Upright::Engine.root.join("app/assets/stylesheets/upright/*.css")]
      .sort
      .map { |f| "upright/#{File.basename(f, '.css')}" }

    stylesheet_link_tag(*stylesheets, **options)
  end
end
