module Auth
  class CommitteesController < ApplicationController
    before_filter :require_user
    include HasAsOf
    expose( :user ) { User.find params[:user_id] if params[:user_id] }
    expose :q_scope do
      scope = user.committees.requestable if params[:action] == 'requestable'
      scope ||= user.committees.scoped if user
      scope ||= Committee.scoped
    end
    expose :q do
      q_scope.search( params[:term] ? { name_cont: params[:term] } : params[:q] )
    end
    expose :committees do
      q.result.ordered.page(params[:page])
    end
    expose :committee
    filter_access_to :new, :create, :edit, :update, :destroy, :show, :index, load_method: :committee
    filter_access_to :tents, :members, require: :enroll, load_method: :committee
    filter_access_to :requestable, require: :show, load_method: :user

    def index
      respond_to do |format|
        format.html { render action: 'index' }
        format.json { render json: committees.map(&:name) }
      end
    end

    # GET /auth/users/:user_id/committees/requestable
    # GET /auth/users/:user_id/committees/requestable.xml
    def requestable
      index
    end

    # GET /auth/committees/:id/tents.pdf
    include UserTentReports
    def tents
      render_user_tent_reports committee.memberships.tents( as_of )
    end

    # GET /auth/committees/:id/members.pdf
    def members
      respond_to do |format|
        format.pdf do
          report = MembershipReport.new( committee, as_of )
          send_data report.to_pdf, filename: "#{committee.name :file}-members.pdf",
            type: 'application/pdf', disposition: 'inline'
        end
      end
    end

    # GET /auth/committees/:id/emplids.pdf
    def empl_ids
      respond_to do |format|
        format.pdf do
          report = EmplIdReport.new( committee, as_of )
          send_data report.to_pdf, filename: "#{committee.name :file}-empl_ids.pdf",
            type: 'application/pdf', disposition: 'inline'
        end
      end
    end

    # POST /auth/committees
    # POST /auth/committees.xml
    def create
      respond_to do |format|
        if committee.save
          format.html { redirect_to(committee, flash: { success: "Committee created." }) }
          format.xml  { render xml: committee, status: :created, location: committee }
        else
          format.html { render action: "new" }
          format.xml  { render xml: committee.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /auth/committees/1
    # PUT /auth/committees/1.xml
    def update
      respond_to do |format|
        if committee.save
          format.html { redirect_to(committee, flash: { success: "Committee updated." }) }
          format.xml  { head :ok }
        else
          format.html { render action: "edit" }
          format.xml  { render xml: committee.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /auth/committees/1
    # DELETE /auth/committees/1.xml
    def destroy
      committee.destroy

      respond_to do |format|
        format.html { redirect_to(committees_url, flash: { success: "Committee destroyed." } ) }
        format.xml  { head :ok }
      end
    end
  end
end
