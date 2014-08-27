(function() {
  define(['oraculum'], function(Oraculum) {
    'use strict';
    return Oraculum.defineMixin('Sortable.CellTemplateMixin', {
      mixinitialize: function() {
        this.addClass('sortable-cell-template-mixin');
        this._updateSortableClass();
        return this._updateDirectionClass();
      },
      _updateSortableClass: function() {
        var sortable;
        sortable = Boolean(this.data('column').get('sortable'));
        return this.toggleClass('sortable', sortable);
      },
      _updateDirectionClass: function() {
        var direction;
        direction = this.data('column').get('sortDirection');
        this.toggleClass('sorted', Boolean(direction));
        this.toggleClass('ascending', direction === -1);
        return this.toggleClass('descending', direction === 1);
      }
    });
  });

}).call(this);
