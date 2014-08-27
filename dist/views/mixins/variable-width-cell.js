(function() {
  define(['oraculum', 'oraculum/mixins/evented'], function(Oraculum) {
    'use strict';
    return Oraculum.defineMixin('VariableWidth.CellTemplateMixin', {
      mixinitialize: function() {
        var column, updateWidth;
        this.addClass('variable-width-cell-template-mixin');
        column = this.data('column');
        updateWidth = (function(_this) {
          return function() {
            return _this._updateWidth(column);
          };
        })(this);
        this.listenTo(column, 'change:width', updateWidth);
        return updateWidth();
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
