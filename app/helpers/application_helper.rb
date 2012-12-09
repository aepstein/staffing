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

  def sortable_label( label )
    ( content_tag(:span, '', class: 'ui-icon ui-icon-arrowthick-2-n-s',
      style: 'float: left;') + label ).html_safe
  end

end

