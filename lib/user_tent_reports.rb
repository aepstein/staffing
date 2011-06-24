module UserTentReports

  module InstanceMethods

    def render_user_tent_reports
      respond_to do |format|
        format.html { render :layout => 'tent' }
        format.pdf do
          if @users
            report = UserTentReport.new( @users, @brand )
            send_data report.to_pdf, :filename => "#{@context.name :file}-tent.pdf",
              :type => 'application/pdf', :disposition => 'inline'
          else
            report = UserTentReport.new( [@user], @brand )
            send_data report.to_pdf, :filename => "#{@user.name :file}-tent.pdf",
              :type => 'application/pdf', :disposition => 'inline'
          end
        end
      end
    end

    private

    def initialize_user_tent_context
      @brand = @committee.brand if @committee
      @brand = Brand.find params[:brand_id] if params[:brand_id]
    end
  end

  module ClassMethods
  end

  def self.included(receiver)
    receiver.before_filter :initialize_user_tent_context
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end

