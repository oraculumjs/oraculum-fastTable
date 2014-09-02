(function() {
  define(['oraculum', 'oraculum/libs', 'oraculum/mixins/evented', 'oraculum/views/mixins/static-classes', 'oraculum/plugins/tabular/views/mixins/row'], function(Oraculum) {
    'use strict';
    var $, defaultTemplate, _;
    $ = Oraculum.get('jQuery');
    _ = Oraculum.get('underscore');
    defaultTemplate = function(_arg) {
      var attr, column, model, value;
      model = _arg.model, column = _arg.column;
      attr = column.get('attribute');
      value = model.escape(attr);
      return "<div>" + value + "</div>";
    };
    return Oraculum.defineMixin('FastRow.ViewMixin', {
      mixinOptions: {
        staticClasses: ['fast-row-mixin'],
        list: {
          defaultTemplate: defaultTemplate
        }
      },
      mixconfig: function(_arg, _arg1) {
        var defaultTemplate, list;
        list = _arg.list;
        defaultTemplate = (_arg1 != null ? _arg1 : {}).defaultTemplate;
        delete list.modelView;
        if (defaultTemplate != null) {
          return list.defaultTemplate = defaultTemplate;
        }
      },
      initModelView: function(column) {
        var $template, model, template, templateMixins, view, viewOptions;
        model = this.model || column;
        template = column.get('template');
        template || (template = this.mixinOptions.list.defaultTemplate);
        if (_.isFunction(template)) {
          template = template({
            model: model,
            column: column
          });
        }
        $template = $(template);
        view = {
          model: model,
          column: column,
          el: $template[0],
          $el: $template,
          render: function() {
            return view;
          }
        };
        viewOptions = this.mixinOptions.list.viewOptions;
        viewOptions = _.extend({
          model: model,
          column: column
        }, viewOptions);
        templateMixins = _.chain(['Evented.Mixin']).union(column.get('templateMixins')).compact().uniq().value();
        this.__factory().handleMixins(view, templateMixins, [viewOptions]);
        return view;
      }
    }, {
      mixins: ['List.ViewMixin', 'StaticClasses.ViewMixin']
    });
  });

}).call(this);
