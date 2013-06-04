module Review
  class MembershipRequestsController < ApplicationController
    before_filter :require_user
    include ControllerModules::MembershipRequestsController
    expose :q_scope do
      review_scope :membership_requests, params[:action]
    end
    expose :membership_requests do
      if params[:review]
        q.result.ordered.page(params[:page])
      else
        q.result.ordered.with_permissions_to(:show).page(params[:page])
      end
    end
    
    def active; index; end
    def inactive; index; end

    private

    def index
      respond_to do |format|
        format.html { render :index }
        format.csv { csv_index }
      end
    end
  end
end
