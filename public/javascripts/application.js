// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$(document).ready(function(){
  $('input.ui-date-picker').datepicker({ dateFormat: 'yy-mm-dd' });
});
$(document).ready(function(){
  $('input.ui-datetime-picker').datetimepicker({
    dateFormat: 'yy-mm-dd', timeFormat: 'hh:mm'
  });
});

