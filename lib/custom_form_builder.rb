class CustomFormBuilder < Formtastic::SemanticFormBuilder

  # A method that deals with calendar_date_select fields
  def ft_calendar_date_select_input(method, options = {})
    html_options = options.delete(:input_html) || {}

    self.label(method, options_for_label(options)) +
    self.send(:calendar_date_select, method, html_options)
  end

  # A method that deals with auto_complete field
  def string_with_auto_complete_input(method, options = {})
    @object_name = @object_name.to_s if @object_name.is_a? Symbol
    html_options = options.delete(:input_html) || {}
    remote_options = options.delete(:remote) || {}

    self.label( method, options_for_label(options)) +
    self.send(:text_field_with_auto_complete, method, default_string_options(method, :string).merge(html_options), remote_options)
  end

  def sanitized_object_name
    @object_name.to_s.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_*$/, "")
  end

  def is_used_as_nested_attribute?
    /\[#{class_name.pluralize}_attributes\]\[[0-9]+\]/.match @object_name.to_s
  end

  def text_field_with_auto_complete(method, tag_options = {}, completion_options = {})
    if completion_options[:child_index]
      unique_object_name = "#{class_name}_#{completion_options[:child_index]}"
    elsif @options[:child_index]
      unique_object_name = "#{class_name}_#{@options[:child_index]}"
    elsif is_used_as_nested_attribute?
      unique_object_name = sanitized_object_name
    elsif !(@object_name.to_s =~ /\[\]$/)
      unique_object_name = sanitized_object_name
    else
      unique_object_name = "#{class_name}_#{Object.new.object_id.abs}"
    end
    completion_options_for_class_name = {
      :url => { :action => "auto_complete_for_#{class_name}_#{method}" },
      :param_name => "#{class_name}[#{method}]"
    }.update(completion_options)
    @template.auto_complete_field_with_style_and_script(unique_object_name,
                                                        method,
                                                        tag_options,
                                                        completion_options_for_class_name
                                                       ) do
      text_field(method, { :id => "#{unique_object_name}_#{method}" }.update(tag_options))
    end
  end

end

