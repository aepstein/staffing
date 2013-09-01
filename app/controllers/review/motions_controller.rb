module Review
  class MotionsController < ApplicationController
    before_filter :require_user
  end
end
