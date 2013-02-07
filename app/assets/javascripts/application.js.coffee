#= require cornell-assemblies-rails
# Sortable cocoon (see https://github.com/nathanvda/cocoon/pull/104)
$ ->
  $.cocoon =
    updateParent: ( item ) ->
      list = $(item).parent().closest("fieldset")
      $.cocoon.updateList(list) if list.data("ordered-by")
    updateList: (list) ->
      field = $(list).data('ordered-by')
      fieldSelector = "[name$='[" + field + "]']"
      $(list).find("> .nested-fields > .control-group " + fieldSelector).each (index, element) ->
        $(element).val( index + 1 )
    setupOrderedList: (list) ->
      $(list).sortable(
        items: $(list).find("> .nested-fields")
        stop: -> $.cocoon.updateList( list ) )
      $(list).unbind('cocoon:after-insert').bind( 'cocoon:after-insert', ( ( event, item ) ->
        $.cocoon.setupOrderedList($(item).parent())
        $.cocoon.setupOrderedList($(item).children().find("fieldset[data-ordered-by]"))
        $.cocoon.updateParent( item ) ) )
      $(list).unbind('cocoon:after-remove').bind( 'cocoon:after-remove', ( ( event, item ) ->
        $.cocoon.updateParent( item ) ) )
  $.cocoon.setupOrderedList( $("fieldset[data-ordered-by]") )

