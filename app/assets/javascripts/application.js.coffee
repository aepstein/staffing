#= require cornell-assemblies-rails
# Sortable cocoon (see https://github.com/nathanvda/cocoon/pull/104)
$ ->
  $.cocoon =
    updateFields: (list) ->
      field = $(list).data('ordered-by')
      fieldSelector = "[name$='[" + field + "]']"
      $(list).find("> .nested-fields > .control-group " + fieldSelector).each (index, element) ->
        $(element).val( index + 1 )
    setupOrdered: ->
      $("fieldset[data-ordered-by]").each (i) ->
        $(this).sortable
          items: $(this).find(".nested-fields")
          stop: -> $.cocoon.updateFields( this )
      $(document).on( 'cocoon:after-insert', ( -> $.cocoon.setupOrdered() ) )
  $.cocoon.setupOrdered()

