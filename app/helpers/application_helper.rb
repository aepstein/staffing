# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
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
end

