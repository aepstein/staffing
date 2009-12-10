# Include hook code here
require 'formtastic_calendar_date_select'
Formtastic::SemanticFormBuilder.send(:include, FormtasticCalendarDateSelect::Formtastic) if defined? Formtastic

