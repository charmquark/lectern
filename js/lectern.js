(function($) {
    $(function() { Lectern.init(); });

    var self = {
        version: '0.1.0',

        components: {},

        add_component: function(component) {
            self.components[component.canon] = self[component.name] = component;
        },

        init: function() {
            $.fn.lectern = __lectern;
            for (canon in self.components) {
                var component = self.components[canon];
                auto_queue(component);
                if (component.init != undefined) {
                    component.init();
                }
            };
        },
    };


    function __lectern(canon, arg) {
        if (typeof canon == 'string') {
            var component = self.components[canon];
            var action, sans;
            if (typeof arg == 'string') {
                action = select_action(component, arg);
                sans = 2;
            }
            else {
                action = select_action(component);
                sans = 1;
            }
            action.apply(this, $(arguments).slice(sans));
        }
        else {
            throw 'invalid arguments to $.lectern()';
        }
    }


    function auto_queue(component) {
        if (component.auto_queue != undefined) {
            $(function() { $(component.auto_queue).lectern(canon); });
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
