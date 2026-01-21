module Upright::ApplicationHelper
  def upright_stylesheet_link_tag(**options)
    stylesheets = Dir[Upright::Engine.root.join("app/assets/stylesheets/upright/*.css")]
      .sort
      .map { |f| "upright/#{File.basename(f, '.css')}" }

    stylesheet_link_tag(*stylesheets, **options)
  end
end
