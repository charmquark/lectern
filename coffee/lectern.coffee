do ->

    self =
        version: '0.1.0'


        add_component: (component) ->
            self.components[component.canon] = self[component.name] = component


        components: {}


        generators:
            data_func: (suffix) ->
                key = 'lectern-' + suffix
                (element, arg) ->
                    if arg?
                        element.data key, arg
                    else
                        element.data key

            get_settings_func: (defaults, list) ->
                (container, options) ->
                    settings = $.extend true, {}, defaults, options
                    unless settings.ignoreData
                        for key in list
                            value = container.data key
                            settings[key] = value if value?
                    settings


        init: ->
            for name, impl of plugins
                $.fn[name] = impl
            for canon, component of self.components
                component.init() if component.init?
                if component.auto_queue?
                    do (component, canon) ->
                        $ -> $(component.auto_queue).lectern canon
            null


        utils:
            add_classes: (settings, element, names) ->
                classes = []
                for i of names
                    classes.push settings.classes[names[i]]
                element.addClass classes.join ' '

    #end Lectern


    plugins =
        dataOr: (key, alt) ->
            result = this.data key
            if result? then result else alt

        lectern: (canon, arg) ->
            if $.type(canon) == 'string'
                component = self.components[canon]
                if $.type(arg) == 'string'
                    action = arg
                    sans = 2
                else
                    action = component.default_action
                    sans = 1
                component.actions[action].apply this, $(arguments).slice sans
            else
                throw 'invalid arguments to $.lectern()'


    window.Lectern = self
    $ self.init
