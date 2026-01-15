class Upright::NodesController < Upright::ApplicationController
  def index
    @nodes = Upright::Node.all
  end
end
