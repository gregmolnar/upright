module Upright
  class NodesController < ApplicationController
    def index
      @nodes = Node.all
    end
  end
end
