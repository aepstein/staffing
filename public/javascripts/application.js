// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$(document).ready(function(){
  $('input.ui-date-picker').datepicker({ dateFormat: 'dd M yy' });
  $('input.ui-datetime-picker').datetimepicker({ dateFormat: 'dd M yy', timeFormat: 'hh:mm'  });
});

