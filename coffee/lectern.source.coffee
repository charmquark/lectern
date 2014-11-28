do ->

    self =

        autoQueue:      '[data-lectern-source]'
        canon:          'source'
        defaultAction:  'create'
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
            @settings = getSettings container, options

            data @container, this

            @modules = (new Module(this, $(elt)) for elt in $(@settings.modules))

            @container.addClass @settings.classes.container

    # end SourceView


    class Module

        constructor: (@sourceView, @element) ->
            @settings = @sourceView.settings

            sliceStart = if @settings.dropFirst then  1 else 0
            sliceStop  = if @settings.dropLast  then -1 else 0
            content = @element.html().split('\n')[sliceStart ... sliceStop]

            dropIndent = @element.dataOr 'dropIndent', 0
            if dropIndent > 0
                for i of content
                    content[i] = content[i].slice dropIndent

            @sourceView.container.append moduleFactories[this.type()] @settings, content


        type: ->
            return 'script' if @element.is 'script'
            return 'style'  if @element.is 'style'
            return 'html'

    # end Module


    moduleFactories =
        html: (settings, content) ->
            Lectern.utils.addClasses settings, $('<div></div>'), ['module', 'htmlModule']
                .text content.join '\n'

        script: (settings, content) ->
            content.unshift '<script>'
            content.push '</script>'
            Lectern.utils.addClasses settings, $('<div></div>'), ['module', 'scriptModule']
                .text content.join '\n'

        style: (settings, content) ->
            content.unshift '<style>'
            content.push '</style>'
            Lectern.utils.addClasses settings, $('<div></div>'), ['module', 'styleModule']
                .text content.join '\n'


    data = Lectern.generators.data self.canon


    getSettings = Lectern.generators.getSettings self.defaults, [
        'modules'
    ]


    Lectern.addComponent self
