class HomeController < ApplicationController
  before_filter :require_user

  # GET /home
  def home
    respond_to do |format|
      format.html # home.html.erb
    end
  end
end

