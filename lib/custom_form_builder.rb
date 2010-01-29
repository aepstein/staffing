class CustomFormBuilder < Formtastic::SemanticFormBuilder

  # A method that deals with calendar_date_select fields
  def ft_calendar_date_select_input(method, options = {})
    html_options = options.delete(:input_html) || {}

    self.label(method, options_for_label(options)) +
    self.send(:calendar_date_select, method, html_options)
  end

  # A method that deals with auto_complete field
  def string_with_auto_complete_input(method, options = {})
    html_options = options.delete(:input_html) || {}
    remote_options = options.delete(:remote) || {}

    self.label( method, options_for_label(options)) +
    self.send(:text_field_with_auto_complete, method, html_options, remote_options)
  end

  def text_field_with_auto_complete(method, local_options, remote_options)
    @template.text_field_with_auto_complete( @object_name, method, objectify_options(local_options), remote_options )
  end

end

