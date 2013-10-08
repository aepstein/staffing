module ControllerModules
  module MeetingsController
    def self.included(receiver)
      receiver.send :include, InstanceMethods
      receiver.send :extend, ClassMethods
      receiver.expose( :starts_at ) do
        if params[:start] && ( sanitized = params[:start].to_i ) > 0
          Time.zone.at sanitized
        else
          nil
        end
      end
      receiver.expose( :ends_at ) do
        if params[:end] && ( sanitized = params[:end].to_i ) > 0
          Time.zone.at sanitized
        else
          nil
        end
      end
      receiver.expose( :committee ) do
        Committee.find params[:committee_id] if params[:committee_id]
      end
      receiver.expose( :q ) do
        q_scope.search( params[:q] )
      end
    end
    
    module ClassMethods
    end

    module InstanceMethods
      protected
      def csv_index
        csv_string = ""
        CSV.generate csv_string do |csv|
          csv << [ 'Unique ID', 'Title', 'Description', 'Date From', 'Date To',
            'Start Time', 'End Time', 'Location', 'Event Website', 'Room',
            'Contact E-Mail', 'Contact Name' ]
          q.result.all.each do |meeting|
            csv << ( [
              "meeting-#{meeting.id}",
              "#{meeting.committee} Meeting",
              meeting.description,
              meeting.starts_at.to_date.to_formatted_s(:db),
              meeting.ends_at.to_date.to_formatted_s(:db),
              meeting.starts_at.strftime("%l:%M %p").strip,
              meeting.ends_at.strftime("%l:%M %p").strip,
              meeting.location,
              ( permitted_to?( :show, meeting ) ? meeting_url(meeting) : '' ),
              meeting.room,
              meeting.effective_contact_email,
              meeting.effective_contact_name
            ] )
          end
        end
        send_data csv_string, disposition: "attachment; filename=meetings.csv",
          type: :csv
      end
    end  
  end
end
