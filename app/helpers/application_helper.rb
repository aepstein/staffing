# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def markdown( content )
    sanitize Markdown.new(content).to_html
  end

  def table_row_tag(increment=true, &block)
    content_tag = content_tag 'tr', capture(&block), :class => table_row_class(increment)
    if block_called_from_erb?(block)
      concat(content_tag)
    else
      content_tag
    end
  end

  def table_row_class(increment=true)
    @table_row_class ||= 'row1'
    out = @table_row_class
    @table_row_class = ( @table_row_class == 'row1' ? 'row2' : 'row1' ) if increment
    @table_row_class = 'row1' if increment == :reset
    out
  end

  def nested_index(parent, children, views=[])
    out = link_to( "List #{children}", polymorphic_path( [ parent, children ] ) )
    if views.length > 0
      out += ": " + views.inject([]) do |memo, view|
        memo << link_to( h( view ), polymorphic_path( [ view, parent, children ] ) )
        memo
      end.join(', ')
    end
    out
  end
end

