module ControllerModules
  module MotionsController
    def self.included(receiver)
      receiver.send :include, InstanceMethods
      receiver.send :extend, ClassMethods
      receiver.expose( :committee ) do
        Committee.find params[:committee_id] if params[:committee_id]
      end
      receiver.expose( :period ) do
        Period.find params[:period_id] if params[:period_id]
      end
      receiver.expose( :q ) do
        q_scope.with_permissions_to(:show).search(
          params[:term] ? { name_cont: params[:term] } : params[:q]
        )
      end
    end
    
    module ClassMethods
    end

    module InstanceMethods
      protected
      def csv_index
      end
    end  
  end
end
