require 'active_model/dirty'

module ActiveModel
  module DirtyWithPrevious
    extend ActiveSupport::Concern
    include ActiveModel::AttributeMethods

    included do
      attribute_method_suffix '_previously_changed?', '_previous_change', '_previously_was'
    end

    private

      # Handle <tt>*_previously_changed?</tt> for +method_missing+.
      def attribute_previously_changed?(attr)
        previous_changes.keys.include?(attr)
      end

      # Handle <tt>*_previous_change</tt> for +method_missing+.
      def attribute_previous_change(attr)
        previous_changes[attr] if attribute_previously_changed?(attr)
      end

      # Handle <tt>*_previously_was</tt> for +method_missing+.
      def attribute_previously_was(attr)
        attribute_previously_changed?(attr) ? attribute_previous_change(attr).first : attribute_was(attr)
      end

  end
end

ActiveRecord::Base.send :include, ActiveModel::DirtyWithPrevious

