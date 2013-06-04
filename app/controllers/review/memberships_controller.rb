module Review
  class MembershipsController < ApplicationController
    before_filter :require_user
    include ControllerModules::MembershipsController
    expose :q_scope do
      review_scope :memberships, params[:action]
    end
    
    def assigned; index; end
    def unassigned; index; end
    def renewable; index; end
    def declined; index; end

    private

    def index
      respond_to do |format|
        format.html { render :index }
        format.csv { csv_index }
      end
    end
  end
end
