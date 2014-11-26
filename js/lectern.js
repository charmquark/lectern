(function($) {
    $(function() { Lectern.init(); });

    var self = {
        version: '0.1.0',

        components: {},

        add_component: function(component) {
            self.components[component.canon] = self[component.name] = component;
        },

        init: function() {
            $.fn.dataOr = __dataOr;
            $.fn.lectern = __lectern;
            for (canon in self.components) {
                var component = self.components[canon];
                auto_queue(component);
                if (component.init !== undefined) {
                    component.init();
                }
            };
        },

        generate: {
            data_func: function(suffix) {
                var key = 'lectern-' + suffix;
                return function(element, arg) {
                    if (arg === undefined) {
                        return element.data(key);
                    }
                    else {
                        return element.data(key, arg);
                    }
                };
            },

            get_settings_func: function(defaults, list) {
                return function(container, options) {
                    var settings = $.extend(true, {}, defaults, options);
                    for (i in list) {
                        var key = list[i];
                        var value = container.data(key);
                        if (value !== undefined) {
                            settings[key] = value;
                        }
                    }
                    return settings;
                };
            }
        },

        util: {
            add_classes: function(component, element, names) {
                for (i in names) {
                    names[i] = component.settings.classes[names[i]];
                }
                return element.addClass(names.join(' '));
            }
        }
    };


    function __dataOr(key, alt) {
        var result = this.data(key)
        return result !== undefined ? result : alt;
    }


    function __lectern(canon, arg) {
        if ($.type(canon) == 'string') {
            var component = self.components[canon];
            var action, sans;
            if ($.type(arg) == 'string') {
                action = select_action(component, arg);
                sans = 2;
            }
            else {
                action = select_action(component);
                sans = 1;
            }
            return action.apply(this, $(arguments).slice(sans));
        }
        else {
            throw 'invalid arguments to $.lectern()';
        }
    }


    function auto_queue(component) {
        if (component.auto_queue !== undefined) {
            $(function() { $(component.auto_queue).lectern(component.canon); });
        }
    }


    function select_action(component, name) {
        if (name === undefined) {
            name = component.default_action;
        }
        return component.actions[name];
    }


    window.Lectern = self;
})(jQuery);
