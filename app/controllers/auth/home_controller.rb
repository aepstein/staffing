module Auth
  class HomeController < ApplicationController
    before_filter :require_user
  end
end
