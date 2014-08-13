#= require cornell-assemblies-rails
$ ->
  $('a[data-toggle="tab"]').on('shown.bs.tab', ( (e) ->
    $($(e.target).attr("href")).find("#meetings-calendar").fullCalendar( 'render' )
  ) )
  $("#meetings-calendar").fullCalendar(
    theme: true,
    allDaySlot: false,
    defaultView: 'agendaWeek',
    header:
      left: 'prev,next today',
      center: 'title'
      right: 'month,agendaWeek,agendaDay',
    events: $("#meetings-calendar").data('url'),
    eventAfterRender: ( ( event, element, view ) ->
      $(element).closest(".fc-event").attr("id",event.id)
      $(element).find(".fc-event-title").after(
        "<div class=\"fc-event-location\">" + event.location + "</div>" )
      false ) )

