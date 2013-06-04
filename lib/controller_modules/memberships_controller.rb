module ControllerModules
  module MembershipsController
    def self.included(receiver)
      receiver.send :include, InstanceMethods
      receiver.expose( :q ) { q_scope.search params[:q] }
      receiver.expose( :memberships ) { q.result.ordered.page params[:page] }
    end

    module InstanceMethods
      protected
      def csv_index
        csv_string = ""
        CSV.generate csv_string do |csv|
          csv << [ 'first', 'last','netid','email','mobile','position','committee',
            'title','vote','period','starts at','ends at','renew until?' ]
          q.result.all.each do |membership|
            next unless permitted_to?( :show, membership )
            membership.enrollments.each do |enrollment|
              next if committee && (enrollment.committee_id != committee.id)
              csv << ( [ membership.user_id? ? membership.user.first_name : '',
                         membership.user_id? ? membership.user.last_name : '',
                         membership.user_id? ? membership.user.net_id : '',
                         membership.user_id? ? membership.user.email : '',
                         membership.user_id? ? membership.user.mobile_phone : '',
                         membership.position.name,
                         enrollment.committee.name,
                         enrollment.title,
                         enrollment.votes,
                         membership.period,
                         membership.starts_at,
                         membership.ends_at,
                         membership.renew_until ? membership.renew_until.to_formatted_s(:rfc822) : ""
              ] )
            end
          end
        end
        send_data csv_string, disposition: "attachment; filename=#{params[:action]}-memberships.csv",
          type: :csv
      end
    end  
  end
end
