do ->

    Lectern.addComponent class Slider extends Lectern.FrameCanvasComponentBase

        @_canon:                'slider'
        @_dataAttrOptions:      ['duration', 'easing', 'indexClasses', 'wrapAround']
        @_defaults:
            classes:
                active:         'lectern-slider-active'
                canvas:         'lectern-slider-canvas'
                caption:        'lectern-slider-caption'
                container:      'lectern-slider-container'
                frame:          'lectern-slider-frame'
                hidden1:        'lectern-slider-hidden1'
                hidden2:        'lectern-slider-hidden2'
                navigator:      'lectern-slider-navigator'
            queries:
                canvas:         '> ul'
                caption:        '> span'
            states:
                active:
                    opacity:    1.0
                    left:       '0px'
                    right:      '0px'
                hidden1:
                    left:       '100%'
                    right:      '-100%'
                hidden2:
                    left:       '-100%'
                    right:      '100%'
            duration:           500
            easing:             'swing'
            indexClasses:       false
            wrapAround:         true


        constructor: (element, settings)->
            super element, settings, SliderFrame, SliderNavigateEvent
            @caption    = this.classyFetch 'caption'


        generateNavigator: ->
            nav = super 'slider', null
            if nav?
                @element.append nav
                for frame in @frames
                    frame.nav.click handleNavigatorNodeClick
            nav


        next: ->
            active = @active
            if active != @last
                this.navigate @frames[active.index + 1]
            else if @settings.wrapAround
                this.navigate @first


        prev: ->
            active = @active
            if active != @first
                this.navigate @frames[active.index - 1]
            else if @settings.wrapAround
                this.navigate @last


        navigationTransition: (fromFrame, toFrame, after) ->
            if fromFrame.index > toFrame.index
                fromFrame.animateTo 'hidden1'
                toFrame.animateTo 'active', 'hidden2', after
            else
                fromFrame.animateTo 'hidden2'
                toFrame.animateTo 'active', 'hidden1', after
            null


    # end Slider


    Slider.Frame = class SliderFrame extends Lectern.FrameBase


        constructor: (slider, index, element) ->
            super slider, index, element, 'hidden1'


    # end SliderFrame


    Slider.NavigateEvent = class SliderNavigateEvent extends Lectern.EventBase


        @_eventModes:   ['before', 'after']
        @_eventName:    'Navigate'


        constructor: (@slider, @fromFrame, @toFrame) ->


    # end SliderNavigateEvent


    handleNavigatorNodeClick = (event) ->
        frame = $(event.target).data('slider-frame')
        if frame?
            frame.container.navigate frame
        null

