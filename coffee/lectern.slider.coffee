do ->

    self =
        autoQueue:      '[data-lectern-slider]'
        canon:          'slider'
        defaultAction:  'create'
        name:           'Slider'


        defaults:
            classes:
                active:     'lectern-slider-active'
                canvas:     'lectern-slider-canvas'
                caption:    'lectern-slider-caption'
                container:  'lectern-slider-container'
                frame:      'lectern-slider-frame'
                hidden1:    'lectern-slider-hidden1'
                hidden2:    'lectern-slider-hidden2'
                navigator:  'lectern-slider-navigator'

            queries:
                canvas:     '> ul'
                caption:    '> span'
                frames:     '> ul > li'

            states:
                active:
                    opacity:    1.0
                    left:       '0px'
                    right:      '0px'

                hidden1:
                    left:   '100%'
                    right:  '-100%'

                hidden2:
                    left:   '-100%',
                    right:  '100%'

            duration:       500
            easing:         'swing'
            indexClasses:   false
            ignoreData:     false
            wrapAround:     true


        actions:
            active: ->
                result = $()
                this.each (idx, container) ->
                    result = result.add data($ container).active
                result

            create: (options) ->
                this.each (idx, container) ->
                    new Slider $(container), options

            next: ->
                this.each (i, container) ->
                    data($ container).next()

            prev: ->
                this.each (i, container) ->
                    data($ container).prev()

    # end self


    self.Slider = class Slider extends Lectern.base.ComponentMain

        constructor: (container, options) ->
            super container, getSettings(container, options)
            data container, this

            @canvas     = this.classyFetch 'canvas'
            @caption    = this.classyFetch 'caption'
            @frames     = (new Frame(this, idx, $(elt)) for elt, idx in fetch('frames'))
            @navigator  = generateNavigator this
            @first      = @frames[0]
            @last       = @frames[@frames.length - 1]
            @active     = @first

            @container.addClass @settings.classes.container
            @container.append @navigator
            @active.jumpTo 'active'


        navigate: (toFrame) ->
            if $.type(toFrame) == 'number'
                toFrame = @frames[toFrame]
            hideState = if toFrame.index > @active.index then 'hidden2' else 'hidden1'
            @active.animateTo hideState
            @active = toFrame.animateTo 'active'


        next: ->
            if @active != @last
                navigate @frames[@active.index + 1]
            else if @settings.wrapAround
                navigate @first


        prev: ->
            if @active != @first
                navigate @frames[@active.index - 1]
            else if @settings.wrapAround
                navigate @last

    # end Slider


    class Frame

        constructor: (@slider, @index, @element) ->
            data @element, this

            @navNode    = null
            @settings   = slider.settings
            @state      = 'hidden1'

            Lectern.utils.addClasses @settings, element, ['frame', 'hidden1']
            if @settings.indexClasses
                element.addClass 'frame-' + @index


        animateTo: (toState) ->
            this.setState toState, @settings.duration, @settings.easing


        jumpTo: (toState) ->
            this.setState toState, 0, 'linear'


        setState: (toState, duration, easing) ->
            unless @state == toState
                @element.animate @settings.states[toState], duration, easing

                @navNode.removeClass   @settings.classes.active if @state == 'active'
                @navNode.addClass      @settings.classes.active if toState == 'active'

                @element.removeClass @settings.classes[@state]
                    .addClass @settings.classes[toState]
                @state = toState
            this

    # end Frame


    data = Lectern.generators.data self.canon


    generateNavigator = (slider) ->
        nav = $ '<ul></ul>'
            .addClass slider.settings.classes.navigator

        for frame in slider.frames
            node = $('<li></li>')
            data node, frame
            node.click onNavigatorClick
            frame.navNode = node
            nav.append node

        nav


    getSettings = Lectern.generators.getSettings self.defaults, [
        'duration', 'easing', 'indexClasses', 'wrapAround'
    ]


    onNavigatorClick = (event) ->
        frame = data $(event.currentTarget)
        frame.slider.navigate frame


    Lectern.addComponent self
