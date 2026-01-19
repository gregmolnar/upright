class Upright::SitesController < Upright::ApplicationController
  def index
    @sites = Upright.sites
  end
end
