do ->

    Lectern.addComponent class SourceView extends Lectern.ComponentBase

        @_canon:                'source'
        @_dataAttrOptions:      ['dropFirst', 'dropLast', 'modules']
        @_defaults:
            classes:
                container:      'lectern-source-container'
                htmlModule:     'lectern-source-module-html'
                module:         'lectern-source-module'
                scriptModule:   'lectern-source-module-script'
                styleModule:    'lectern-source-module-style'
            dropFirst:  true
            dropLast:   true
            modules:    null


        constructor: (element, settings)->
            super element, settings

            @modules = (new SourceViewModule(this, $(elt)) for elt in $(settings.modules))


    SourceView.Module = class SourceViewModule

        constructor: (@sourceView, @element) ->
            @settings   = settings = sourceView.settings
            sliceStart  = if settings.dropFirst then  1 else 0
            sliceStop   = if settings.dropLast  then -1 else 0
            content     = element.html().split("\n")[sliceStart ... sliceStop]
            dropIndent  = element.dataElse 'dropIndent', 0
            @type       = type = findType element

            if dropIndent > 0
                for line, i in content
                    if line[0 ... 2] == '//'
                        content[i] = '//' + line.slice dropIndent + 2
                    else
                        content[i] = line.slice dropIndent

            @markup = markup = moduleFactories[type] content
            sourceView.addClasses ['module', "#{type}Module"], markup
            sourceView.element.append markup


    findType = (element) ->
        return 'script' if element.is 'script'
        return 'style'  if element.is 'style'
        return 'html'


    moduleFactories =
        html: (content) ->
            $ '<div></div>'
                .text content.join "\n"

        script: (content) ->
            content.unshift '<script>'
            content.push    '</script>'
            $ '<div></div>'
                .text content.join "\n"

        style: (content) ->
            content.unshift '<style>'
            content.push    '</style>'
            $ '<div></div>'
                .text content.join "\n"

