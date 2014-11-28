do ->

    self =
        version: '0.1.3'


        addBase: (C) ->
            self.base[C.name] = C


        addComponent: (component) ->
            self.components[component.canon] = self[component.name] = component


        base: {}


        components: {}


        generators:
            data: (suffix) ->
                key = 'lectern-' + suffix
                (element, arg) ->
                    if arg?
                        element.data key, arg
                    else
                        element.data key

            getSettings: (defaults, list) ->
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
                if component.autoQueue?
                    do (component, canon) ->
                        $ -> $(component.autoQueue).lectern canon
            null


        utils:
            addClasses: (settings, element, names) ->
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
                    action = component.defaultAction
                    sans = 1
                component.actions[action].apply this, $(arguments).slice sans
            else
                throw 'invalid arguments to $.lectern()'


    self.addBase class ComponentMain

        constructor: (@container, @settings) ->
            container.addClass @settings.classes.container


        fetch: (sel) ->
            $(@settings.queries[sel], @container)


        classyFetch: (sel) ->
            this.fetch sel
                .addClass @settings.classes[sel]

    # end ComponentMain


    window.Lectern = self
    $ self.init
