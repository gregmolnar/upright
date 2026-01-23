class Upright::JobsController < Upright::ApplicationController
  def show
    @frame_url = mission_control_jobs.root_path
  end
end
