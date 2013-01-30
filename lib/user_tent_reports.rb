module UserTentReports

  module InstanceMethods

    def render_user_tent_reports( tents )
      respond_to do |format|
        format.pdf do
          report = UserTentReport.new( tents, brand )
          send_data report.to_pdf, filename: "#{(committee || user).name :file}-tent.pdf",
            type: 'application/pdf', disposition: 'inline'
        end
      end
    end
  end

  module ClassMethods
  end

  def self.included(receiver)
    receiver.send( :expose, :brand ) do
      if params[:brand_id]
        Brand.find params[:brand_id]
      else
        Brand.first
      end
    end
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end

