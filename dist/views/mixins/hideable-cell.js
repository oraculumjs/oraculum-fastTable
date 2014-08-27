(function() {
  define(['oraculum'], function(Oraculum) {
    'use strict';
    return Oraculum.defineMixin('Hideable.CellTemplateMixin', {
      mixinitialize: function() {
        var display, hidden;
        this.addClass('hideable-cell-template-mixin');
        hidden = this.data('column').get('hidden');
        display = Boolean(hidden) ? 'none' : '';
        return this.css({
          display: display
        });
      }
    });
  });

}).call(this);
