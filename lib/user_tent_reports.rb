module UserTentReports

  module InstanceMethods
    def render_user_tent_reports
      respond_to do |format|
        format.html { render :layout => 'tent' }
        format.pdf do
          if @users
            report = UserTentReport.new(@users)
            send_data report.to_pdf, :filename => "#{@users.name :file}-tent.pdf",
              :type => 'application/pdf', :disposition => 'inline'
          else
            report = UserTentReport.new([@user])
            send_data report.to_pdf, :filename => "#{@user.name :file}-tent.pdf",
              :type => 'application/pdf', :disposition => 'inline'
          end
        end
      end
    end
  end

  module ClassMethods
  end

  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end

