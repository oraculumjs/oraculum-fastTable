(function() {
  define(['oraculum', 'oraculum/libs', 'oraculum/views/mixins/static-classes'], function(Oraculum) {
    'use strict';
    var $;
    $ = Oraculum.get('jQuery');
    return Oraculum.defineMixin('FastRow.ViewMixin', {
      mixinOptions: {
        staticClasses: ['fast-row-mixin']
      },
      mixinitialize: function() {
        var debouncedRender;
        debouncedRender = _.debounce((function(_this) {
          return function() {
            return _this.render();
          };
        })(this));
        this.listenTo(this.model, 'all', debouncedRender);
        this.listenTo(this.collection, 'change', debouncedRender);
        return this.listenTo(this.collection, 'add remove reset sort', (function(_this) {
          return function() {
            return _this.render();
          };
        })(this));
      },
      render: function() {
        this.$el.empty();
        this.collection.each((function(_this) {
          return function(column) {
            var $template;
            $template = _this._getTemplate(column);
            return _this.$el.append($template);
          };
        })(this));
        return this;
      },
      _getTemplate: function(column) {
        var $template, template, templateMixins;
        template = column.get('template');
        if (template == null) {
          throw new TypeError('column.template is not defined');
        }
        if (_.isFunction(template)) {
          template = template({
            model: this.model,
            column: column
          });
        }
        $template = $(template);
        $template.data({
          model: this.model,
          column: column
        });
        if (templateMixins = column.get('templateMixins')) {
          this.__factory().handleMixins($template, templateMixins, {
            model: this.model,
            column: column
          });
        }
        return $template;
      }
    }, {
      mixins: ['StaticClasses.ViewMixin']
    });
  });

}).call(this);
