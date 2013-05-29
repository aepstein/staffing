module HasAsOf
  included do
    expose :as_of do
      begin
        date = if params[:as_of]
          Date.parse( params[:as_of] )
        end
      rescue ArgumentError
        flash[:error] = 'Invalid date supplied for report.'
      end
      date ||= Time.zone.today
      date
    end
  end
end
