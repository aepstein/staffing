# FormtasticCalendarDateSelect
module FormtasticCalendarDateSelect
  module Formtastic
    # A method that deals with calendar_date_select fields
    def ft_calendar_date_select_input(method, options = {})
      html_options = options.delete(:input_html) || {}

      self.label(method, options_for_label(options)) +
      self.send(:calendar_date_select, method, html_options)
    end
  end
end

