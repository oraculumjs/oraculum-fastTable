(function() {
  define(['oraculum', 'oraculum/mixins/evented'], function(Oraculum) {
    'use strict';
    return Oraculum.defineMixin('VariableWidth.CellTemplateMixin', {
      mixinitialize: function() {
        var column;
        this.addClass('variable-width-cell-mixin');
        column = this.data('column');
        this.listenTo(column, 'change:width', (function(_this) {
          return function() {
            return _this._updateWidth(column);
          };
        })(this));
        return this._updateWidth(column);
      },
      _updateWidth: function(column) {
        var width;
        if ((width = column.get('width')) == null) {
          return;
        }
        return this.css({
          width: width
        });
      }
    }, {
      mixins: ['Evented.Mixin']
    });
  });

}).call(this);
