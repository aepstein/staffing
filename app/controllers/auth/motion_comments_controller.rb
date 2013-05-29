module Auth
  class MotionCommentsController < ApplicationController
    expose( :motion ) { Motion.find params[:motion_id] if params[:motion_id] }
    expose( :user ) { User.find params[:user_id] if params[:user_id] }
    expose :q_scope do
      scope ||= motion.meetings if motion
      scope ||= user.meetings if user
      scope
    end
    expose( :q ) { q_scope.search( params[:q] ) }
    expose :motion_comments do
      q.result.with_permissions_to(:show).ordered.page(params[:page])
    end
    expose :motion_comment do
      if params[:id]
        MotionComment.find(params[:id])
      else
        motion.motion_comments.build( params[:motion_comment] ) do |comment|
          comment.user = current_user
        end
      end
    end
    expose( :role ) { permitted_to?(:staff, meeting) ? :staff : :default }
    before_filter :require_user
    filter_access_to :new, :create, :edit, :update, :destroy, :show,
      attribute_check: true, load_method: :motion_comment
    before_filter :reciprocate_attachments, only: [ :create, :update ]

    def index
      respond_to do |format|
        format.pdf do
          if motion.motion_comments.any?
            report = MotionCommentReport.new( motion )
            send_data report.to_pdf, filename: "comments-#{motion.to_s :file}.pdf",
              type: 'application/pdf', disposition: 'inline'
          else
            redirect_to( motion, flash: { error: 'No comments provided for the motion.' } )
          end
        end
      end
    end

    # POST /motions/:motion_id/motion_comments
    # POST /motions/:motion_id/motion_comments.xml
    def create
      respond_to do |format|
        if motion_comment.save
          format.html { redirect_to( motion_comment.motion, flash: { success: 'Motion comment created.' } ) }
          format.xml  { render xml: motion_comment, status: :created, location: motion_comment }
        else
          format.html { render action: "new" }
          format.xml  { render xml: motion_comment.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /motion_comments/1
    # PUT /motion_comments/1.xml
    def update
      motion_comment.assign_attributes params[:motion_comment]
      respond_to do |format|
        if motion_comment.save
          format.html { redirect_to motion_comment.motion, flash: { success: 'Motion comment updated.' } }
          format.xml  { head :ok }
        else
          format.html { render action: "edit" }
          format.xml  { render xml: motion_comment.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /motion_comments/1
    # DELETE /motion_comments/1.xml
    def destroy
      motion_comment.destroy

      respond_to do |format|
        format.html { redirect_to( motion_url( motion_comment.motion ),
          flash: { success: "Motion comment destroyed." } ) }
        format.xml  { head :ok }
      end
    end

    private

    def reciprocate_attachments
      motion_comment.attachments.each { |attachment| attachment.attachable = motion_comment }
    end
  end
end
