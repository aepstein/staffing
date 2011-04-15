module Notifiable
  module InstanceMethods
  end

  module ClassMethods

    def notifiable_events( *events )
      events.flatten.each do |event|
        scope "no_#{event}_notice".to_sym, where( "#{event}_notice_at".to_sym => nil )
        scope "no_#{event}_notice_since".to_sym, lambda { |time|
          t = arel_table
          f = arel_table["#{event}_notice_at".to_sym]
          where( f.eq( nil ).or( f.lt( time ) ) )
        }
        define_method "send_#{event}_notice!".to_sym do
          "#{self.class}Mailer".constantize.send( "#{event}_notice", self ).deliver
          send "#{event}_notice_at=", Time.zone.now
          save! :validate => false
        end
      end
    end

  end

  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end

