(function() {
  define(['oraculum', 'fastTable/views/mixins/hideable-cell', 'fastTable/views/mixins/sortable-cell'], function(Oraculum) {
    'use strict';
    return Oraculum.defineMixin('Cell.TemplateMixin', {
      mixinitialize: function() {
        var attribute;
        attribute = this.data('column').get('attribute');
        this.addClass('cell');
        this.addClass('cell-mixin');
        return this.addClass(("" + attribute + "-cell").replace(/[\.\s]/, '-'));
      }
    }, {
      mixins: ['Hideable.CellTemplateMixin', 'Sortable.CellTemplateMixin']
    });
  });

}).call(this);
