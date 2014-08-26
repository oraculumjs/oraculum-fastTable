(function() {
  define(['oraculum'], function(Oraculum) {
    'use strict';
    return Oraculum.defineMixin('Hideable.CellTemplateMixin', {
      mixinitialize: function() {
        this.addClass('hideable-cell-mixin');
        return this.toggle(!this.data('column').get('hidden'));
      }
    });
  });

}).call(this);
