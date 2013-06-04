module ControllerModules
  module MembershipRequestsController
    def self.included(receiver)
      receiver.send :include, InstanceMethods
      receiver.expose :q do
        q_scope.search( params[:q] )
      end
    end

    module InstanceMethods
    protected
      def index_csv
        csv_string = CSV.generate do |csv|
          csv << %w( net_id first last status committee until )
         q.result.ordered.all.each do |membership_request|
            csv << [ membership_request.user.net_id, membership_request.user.first_name,
              membership_request.user.last_name, membership_request.user.status,
              membership_request.committee, membership_request.ends_at ]
          end
        end
        send_data csv_string, disposition: "attachment; filename=membership_requests.csv",
          type: :csv
      end
    end  
  end
end
