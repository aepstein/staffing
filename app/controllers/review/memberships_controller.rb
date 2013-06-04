module Review
  class MembershipsController < ApplicationController
    before_filter :require_user
    include ControllerModules::MembershipsController
    expose :q_scope do
      case params[:action]
      when 'assigned'
        current_user.reviewable_memberships.assigned
      when 'unassigned'
        current_user.reviewable_memberships.unassigned
      when 'renewable'
        current_user.renewable_memberships.unrenewed.renewal_undeclined
      when 'declined'
        current_user.renewable_memberships.renewal_declined
      end
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
