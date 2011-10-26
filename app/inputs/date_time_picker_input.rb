class DateTimePickerInput < Formtastic::Inputs::StringInput
  def wrapper_html_options
    super.merge( :class => 'datetime' )
  end

  def input_html_options
    super.merge( :class => 'ui-datetime-picker',
      :value => object.send(method).try( :strftime, '%Y-%m-%d %I:%M %P' ) )
  end
end

