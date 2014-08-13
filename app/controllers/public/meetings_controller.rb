module Public
  class MeetingsController < ApplicationController
    include ControllerModules::MeetingsController
    expose :q_scope do
      scope ||= committee.meetings if committee
      scope ||= Meeting.all
      scope = scope.where { |m| m.starts_at.gte( e_starts ) }
      scope = scope.where { |m| m.starts_at.lte( e_ends ) }
      scope
    end
    expose( :meetings ) do
      q.result.ordered.page(params[:page])
    end
    expose( :e_starts ) { starts_at || Time.zone.now - 90.days }
    expose( :e_ends ) { ends_at || Time.zone.now + 90.days }
    expose :title do
      case params[:action]
      when 'index'
        ( committee ? committee.name + ' ' : '' ) +
        "Meetings for #{e_starts.to_s :us_ordinal} through #{e_ends.to_s :us_ordinal}"
      else
        ''
      end
    end
    
    def index
     respond_to do |format|
       format.html { render action: 'index' }
       format.csv { csv_index }
     end
    end
  end
end
