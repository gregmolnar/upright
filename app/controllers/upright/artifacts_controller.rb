module Upright
  class ArtifactsController < ApplicationController
    def show
      @artifact = ActiveStorage::Attachment.find(params[:id])
    end
  end
end
