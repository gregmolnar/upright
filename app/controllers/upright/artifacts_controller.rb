class Upright::ArtifactsController < Upright::ApplicationController
  def show
    @artifact = ActiveStorage::Attachment.find(params[:id])
  end
end
