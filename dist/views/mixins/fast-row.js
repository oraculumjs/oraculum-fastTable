(function() {
  define(['oraculum', 'oraculum/libs', 'oraculum/mixins/evented', 'oraculum/views/mixins/static-classes', 'oraculum/plugins/tabular/views/mixins/row'], function(Oraculum) {
    'use strict';
    var $, _, defaultTemplate;
    $ = Oraculum.get('jQuery');
    _ = Oraculum.get('underscore');
    defaultTemplate = function(arg) {
      var attr, column, model, value;
      model = arg.model, column = arg.column;
      attr = column.get('attribute');
      value = model.escape(attr);
      return "<div>" + value + "</div>";
    };
    return Oraculum.defineMixin('FastRow.ViewMixin', {
      mixinOptions: {
        list: {
          defaultTemplate: defaultTemplate
        }
      },
      mixconfig: function(arg, arg1) {
        var defaultTemplate, list;
        list = arg.list;
        defaultTemplate = (arg1 != null ? arg1 : {}).defaultTemplate;
        delete list.modelView;
        if (defaultTemplate != null) {
          return list.defaultTemplate = defaultTemplate;
        }
      },
      initModelView: function(column) {
        var $template, factory, mixins, model, options, template, templateMixins, view;
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
            return this;
          }
        };
        factory = this.__factory();
        options = this.mixinOptions.list.viewOptions;
        options = factory.composeConfig(options, {
          model: model,
          column: column
        });
        if (_.isFunction(options)) {
          options = options.call(this, {
            model: model,
            column: column
          });
        }
        templateMixins = _.chain(['Evented.Mixin']).union(column.get('templateMixins')).compact().uniq().value();
        mixins = factory.composeMixinDependencies(templateMixins);
        factory.enhanceObject(factory, 'Oraculum-fastTable.Template', {
          mixins: mixins
        }, view);
        factory.handleMixins(view, mixins, [options]);
        return view;
      }
    }, {
      mixins: ['List.ViewMixin']
    });
  });

}).call(this);
