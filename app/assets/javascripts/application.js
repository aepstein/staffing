//= require cornell-assemblies-rails
// Sortable cocoon (see https://github.com/nathanvda/cocoon/pull/104)
(function($) {
  $.fn.parentSiblings = function(selector) {
    return $(this).parent().siblings(selector);
  }
  $.cocoon = {
    ordered: {
      options: {
        items: '> .nested-fields',
        stop: function(e, ui) {
          $.cocoon.ordered._updateFields(this)
        },
        start: function(e, ui) { }
      },
      _updateFields: function(element) {
        console.log(element)
        console.log($(element).data('fieldSearch'))
        console.log($(element).find($(element).data('fieldSearch')))

        $(element).find($(element).data('fieldSearch')).each(function(index, element) {
          $(element).val(index+1);
        });
      },
      setup: function() {
        $('fieldset[data-ordered_by]').each(function(index, element) {
          var field = $(element).data('ordered_by');
          var fieldSelector = "[name*='[" + field + "]']"
          var fieldGroupSelector = "> .cocoon > .nested-fields"
          var orderFieldSelector = "> .nested-fields " + fieldSelector;
          var fieldSearch = "> .cocoon " + orderFieldSelector;

          $(element).find('.cocoon').data('fieldSearch', orderFieldSelector).sortable($.cocoon.ordered.options);

          $(element).unbind('cocoon:after-insert').bind('cocoon:after-insert', function(e, node) {
            var nextOrder = 0;

            if ($(element).find(fieldGroupSelector).is(node)) {
              $(element).find(fieldSearch).each(function() {
                nextOrder = Math.max(nextOrder, Number($(this).val()));
              });

              $(node).find(fieldSelector).val(nextOrder + 1)
            }
          });
        });

        $(document).on('cocoon:after-insert', function() { $.cocoon.ordered.setup(); });
      }
    },
  };

  $(function() { $.cocoon.ordered.setup(); });
})(jQuery);

