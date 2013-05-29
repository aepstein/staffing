module Public
  class CommitteesController < ApplicationController
    before_filter :require_no_user
    include HasAsOf
    expose :q_scope do
      scope ||= Committee.scoped
    end
    expose :q do
      q_scope.search( params[:term] ? { name_cont: params[:term] } : params[:q] )
    end
    expose :committees do
      q.result.ordered.page(params[:page])
    end
    expose :committee
  end
end
