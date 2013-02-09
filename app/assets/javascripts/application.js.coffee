#= require cornell-assemblies-rails
# Sortable cocoon (see https://github.com/nathanvda/cocoon/pull/104)
$ ->
  $.cornellUI =
    applyBehaviors: (scope) ->
      console.log( scope )
      $(scope).find("input.ui-date-picker").each (i) ->
        $(this).datepicker
          altFormat: "yy-mm-dd"
          dateFormat: "mm/dd/yy"
          altField: $(this).next()
      $(scope).find("input.ui-datetime-picker").each (i) ->
        $(this).datetimepicker
          altFormat: "yy-mm-dd"
          dateFormat: "mm/dd/yy"
          altField: $(this).next()
          altFieldTimeOnly: false
          altTimeFormat: "HH:mm:'00'"
          dateFormat: 'mm/dd/yy'
          timeFormat: "hh:mm:'00' tt"
      $(scope).find(".best_in_place").best_in_place()
      $(scope).find("input.colorpicker").colorpicker()
#      $(scope).find(".autocomplete").each (i) ->
#        sourceURL = $(this).data("url")
#        $(this).autocomplete(
#          source: ( (request, response) ->
#            console.log
#            result = $.getJSON( sourceURL, { term: request.term.split().pop().replace(/^\s+/,"") } )
#            response.apply( null, result ) ),
#          minLength: 2 )
#  $.cornellUI.applyBehaviors( $("body") )

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
    setupList: (list) ->
      $(list).unbind('cocoon:after-insert').bind( 'cocoon:after-insert', ( ( event, item ) ->
        $.cocoon.setupList($(item).parent())
        $.cocoon.setupList($(item).children().find("fieldset.cocoon"))
        $.cornellUI.applyBehaviors( item ) ) )
    setupOrderedList: (list) ->
      $(list).sortable(
        items: $(list).find("> .nested-fields")
        stop: -> $.cocoon.updateList( list ) )
      $(list).bind( 'cocoon:after-insert', ( ( event, item ) ->
        $.cocoon.setupOrderedList($(item).parent())
        $.cocoon.setupOrderedList($(item).children().find("fieldset[data-ordered-by]"))
        $.cocoon.updateParent( item ) ) )
      $(list).unbind('cocoon:after-remove').bind( 'cocoon:after-remove', ( ( event, item ) ->
        $.cocoon.updateParent( item ) ) )
  $.cocoon.setupList( $("fieldset.cocoon") )
  $.cocoon.setupOrderedList( $("fieldset[data-ordered-by]") )

