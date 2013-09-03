# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def nested_index(parent, children, views=[])
    out = link_to( "List #{children}", polymorphic_path( [ parent, children ] ) )
    if views.length > 0
      out += ": ".html_safe + views.inject([]) do |memo, view|
        memo << link_to( view, polymorphic_path( [ view, parent, children ] ) )
        memo
      end.join(', ').html_safe
    end
    out.html_safe
  end
  def input_calendar_button
    calendar_icon = content_tag(:i, nil, {  class: "icon-calendar",
      data: { :"time-icon" => "icon-time", :"date-icon" => "icon-calendar"} })
    content_tag(:span, calendar_icon, { class: "add-on" })
  end
end

