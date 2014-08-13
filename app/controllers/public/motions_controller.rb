module Public
  class MotionsController < ApplicationController
    include ControllerModules::MotionsController
    expose :q_scope do
      scope ||= committee.motions if committee
      scope ||= Motion.all
      scope = if period
        scope.where { |m| m.period_id.eq( period.id ) }
      else
        scope.current
      end
      scope
    end
    expose( :motions ) do
      q.result.with_permissions_to(:show).ordered.page(params[:page])
    end
    expose :title do
      case params[:action]
      when 'index'
        ( committee.blank? && period.blank? ? "Current " : "" ) +
        ( committee ? committee.name + ' ' : '' ) +
        "Motions" +
        ( committee && period.blank? ? " for #{committee.periods.active}" : '' ) +
        ( committee.blank? && period ? " for #{period}" : ''  )
      else
        ''
      end
    end
    
    def index
     respond_to do |format|
       format.html { render action: 'index' }
     end
    end
  end
end
