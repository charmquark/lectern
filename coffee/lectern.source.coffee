do ->

    self =

        auto_queue:     '[data-lectern-source]'
        canon:          'source'
        default_action: 'create'
        name:           'Source'


        defaults:
            classes: 
                container:      'lectern-source-container'
                htmlModule:      'lectern-source-module-html'
                module:         'lectern-source-module'
                scriptModule:   'lectern-source-module-script'
                styleModule:    'lectern-source-module-style'

            dropFirst:  true
            dropLast:   true
            ignoreData: false
            modules:    undefined


        actions:
            create: (options) ->
                this.each (idx, container) ->
                    new SourceView $(container), options
                this

    # end self


    class SourceView

        constructor: (@container, options) ->
            @settings = get_settings container, options

            data @container, this

            @modules = (new Module(this, $(elt)) for elt in $(@settings.modules))

            @container.addClass @settings.classes.container

    # end SourceView


    class Module

        constructor: (@source_view, @element) ->
            @settings = @source_view.settings

            slice_start = if @settings.dropFirst then  1 else 0
            slice_stop  = if @settings.dropLast  then -1 else 0
            content = @element.html().split('\n')[slice_start ... slice_stop]

            drop_indent = @element.dataOr 'dropIndent', 0
            if drop_indent > 0
                for i of content
                    content[i] = content[i].slice drop_indent

            @source_view.container.append module_factories[this.type()] @settings, content


        type: ->
            return 'script' if @element.is 'script'
            return 'style'  if @element.is 'style'
            return 'html'

    # end Module


    module_factories =
        html: (settings, content) ->
            Lectern.utils.add_classes settings, $('<div></div>'), ['module', 'htmlModule']
                .text content.join '\n'

        script: (settings, content) ->
            content.unshift '<script>'
            content.push '</script>'
            Lectern.utils.add_classes settings, $('<div></div>'), ['module', 'scriptModule']
                .text content.join '\n'

        style: (settings, content) ->
            content.unshift '<style>'
            content.push '</style>'
            Lectern.utils.add_classes settings, $('<div></div>'), ['module', 'styleModule']
                .text content.join '\n'


    data = Lectern.generators.data_func self.canon


    get_settings = Lectern.generators.get_settings_func self.defaults, [
        'modules'
    ]


    Lectern.add_component self
