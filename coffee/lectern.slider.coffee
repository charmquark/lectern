do ->

    self =
        auto_queue:     '[data-lectern-slider]'
        canon:          'slider'
        default_action: 'create'
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


    self.Slider = class Slider

        constructor: (@container, options) ->
            @settings = get_settings container, options

            fetch_and_classify = (sel) =>
                $(@settings.queries[sel], @container).addClass @settings.classes[sel]

            data @container, this

            @canvas     = fetch_and_classify 'canvas'
            @caption    = fetch_and_classify 'caption'
            @frames     = (new Frame(this, idx, $(elt)) for elt, idx in fetch('frames'))
            @navigator  = generate_navigator this
            @first      = @frames[0]
            @last       = @frames[@frames.length - 1]
            @active     = @first

            @container.addClass @settings.classes.container
            @container.append @navigator
            @active.jump_to 'active'


        navigate: (to_frame) ->
            if $.type(to_frame) == 'number'
                to_frame = @frames[to_frame]
            hide_state = if to_frame.index > @active.index then 'hidden2' else 'hidden1'
            @active.animate_to hide_state
            @active = to_frame.animate_to 'active'


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

            @nav_node   = null
            @settings   = slider.settings
            @state      = 'hidden1'

            Lectern.utils.add_classes @settings, element, ['frame', 'hidden1']
            if @settings.indexClasses
                element.addClass 'frame-' + @index


        animate_to: (to_state) ->
            this.set_state to_state, @settings.duration, @settings.easing


        jump_to: (to_state) ->
            this.set_state to_state, 0, 'linear'


        set_state: (to_state, duration, easing) ->
            unless @state == to_state
                @element.animate @settings.states[to_state], duration, easing

                @nav_node.removeClass   @settings.classes.active if @state == 'active'
                @nav_node.addClass      @settings.classes.active if to_state == 'active'

                @element.removeClass @settings.classes[@state]
                    .addClass @settings.classes[to_state]
                @state = to_state
            this

    # end Frame


    data = Lectern.generators.data_func self.canon


    generate_navigator = (slider) ->
        nav = $ '<ul></ul>'
            .addClass slider.settings.classes.navigator

        for frame in slider.frames
            node = $('<li></li>')
            data node, frame
            node.click on_navigator_click
            frame.nav_node = node
            nav.append node

        nav


    get_settings = Lectern.generators.get_settings_func self.defaults, [
        'duration', 'easing', 'indexClasses', 'wrapAround'
    ]


    on_navigator_click = (event) ->
        frame = data $(event.target)
        frame.slider.navigate frame


    Lectern.add_component self
