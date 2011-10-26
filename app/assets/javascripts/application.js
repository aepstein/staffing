// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require jquery-ui-timepicker-addon
//= require autocomplete-rails

// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$(document).ready(function(){
  $('input.ui-date-picker').datepicker({ dateFormat: 'yy-mm-dd' });
  $('input.ui-datetime-picker').datetimepicker({ ampm: true,
    dateFormat: 'yy-mm-dd', timeFormat: 'hh:mm tt'  });
});

