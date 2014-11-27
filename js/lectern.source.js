(function($) {
    var self = {
        auto_queue: '[data-lectern-source]',
        canon: 'source',
        default_action: 'create',
        name: 'Source',

        defaults: {
            classes: {
                container: 'lectern-source-container',
                htmlModule: 'lectern-source-module-html',
                module: 'lectern-source-module',
                scriptModule: 'lectern-source-module-script',
                styleModule: 'lectern-source-module-style'
            },

            dropFirst: true,
            dropLast: true,
            ignoreData: false,
            modules: undefined
        },

        actions: {
            create: function(options) {
                this.each(function(idx, container) {
                    container = $(container);
                    var settings = get_settings(container, options);
                    var source = {
                        container: container,
                        settings: settings
                    };
                    data(container, source);
                    container.addClass(settings.classes.container);

                    var modules = source.modules = $(settings.modules);
                    modules.each(function(i, elt) {
                        add_module(source, $(elt));
                    });
                });
                return this;
            }
        }
    };


    function add_module(source, module) {
        module_factories[module_type(module)](source, module);
    }


    var data = Lectern.generate.data_func(self.canon);


    var get_settings = Lectern.generate.get_settings_func(
        self.defaults,
        ['modules']
    );


    var module_factories = {
        html: function(source, module) {
            var mod = Lectern.util.add_classes(source, $('<div></div>'), ['module', 'htmlModule']);
            var slice_start = source.settings.dropFirst ? 1 : 0;
            var slice_stop = source.settings.dropLast ? -1 : 0;
            var html = module.html().split('\n').slice(slice_start, slice_stop);

            var drop_indent = module.dataOr('dropIndent', 0);
            if (drop_indent > 0) {
                for (i in html) {
                    html[i] = html[i].slice(drop_indent);
                }
            }

            mod.text(html.join('\n'));
            source.container.append(mod);
        },

        script: function(source, module) {
            var mod = Lectern.util.add_classes(source, $('<div></div>'), ['module', 'scriptModule']);
            var slice_start = source.settings.dropFirst ? 1 : 0;
            var slice_stop = source.settings.dropLast ? -1 : 0;
            var code = module.html().split('\n').slice(slice_start, slice_stop);

            var drop_indent = module.dataOr('dropIndent', 0);
            if (drop_indent > 0) {
                for (i in code) {
                    code[i] = code[i].slice(drop_indent);
                }
            }

            code.unshift('<script>');
            code.push('</script>');
            mod.text(code.join('\n'));
            source.container.append(mod);
        },

        style: function(source, module) {
            var mod = Lectern.util.add_classes(source, $('<div></div>'), ['module', 'styleModule']);
            var slice_start = source.settings.dropFirst ? 1 : 0;
            var slice_stop = source.settings.dropLast ? -1 : 0;
            var code = module.html().split('\n').slice(slice_start, slice_stop);

            var drop_indent = module.dataOr('dropIndent', 0);
            if (drop_indent > 0) {
                for (i in code) {
                    code[i] = code[i].slice(drop_indent);
                }
            }

            code.unshift('<style>');
            code.push('</style>');
            mod.text(code.join('\n'));
            source.container.append(mod);
        }
    };


    function module_type(module) {
        if (module.is('script')) {
            return 'script';
        }
        else if (module.is('style')) {
            return 'style';
        }
        else {
            return 'html';
        }
    }


    Lectern.add_component(self);
})(jQuery);
