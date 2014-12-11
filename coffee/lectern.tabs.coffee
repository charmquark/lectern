do ->

    Lectern.addComponent class TabView extends Lectern.FrameCanvasComponentBase

        @_canon:            'tabs'
        @_dataAttrOptions:  ['duration', 'easing', 'height', 'indexClasses']
        @_defaults:
            classes: 
                active:     'lectern-tabs-active'
                canvas:     'lectern-tabs-canvas'
                container:  'lectern-tabs-container'
                frame:      'lectern-tabs-frame'
                inactive:   'lectern-tabs-inactive'
                tab:        'lectern-tabs-tab'
                tabBar:     'lectern-tabs-tabbar'
            queries:
                canvas:     '> ul'
                tab:        '> .tab'
            states:
                active:
                    opacity:    1
                inactive:
                    opacity:    0
            duration:       200
            easing:         'swing'
            height:         null
            indexClasses:   false
            ignoreData:     false


        constructor: (element, settings) ->
            super element, settings, TabFrame, TabNavigateEvent
            this.addClass 'tabBar', @navigator
            this.findFrameHeight()


        findFrameHeight: ->
            frames = @frames
            if @settings.height?
                height = @settings.height
            else
                height = 0
                for f in frames
                    fh = f.element.outerHeight()
                    height = fh if fh > height
            @element.height height + @navigator.outerHeight()
            @canvas.innerHeight height
            for f in frames
                f.element.css {'max-height': height}
            this


        generateNavigator: ->
            nav = super 'tab', ['tab', 'inactive']
            if nav?
                @element.prepend nav
                for frame in @frames
                    frame.nav.html frame.label
                    frame.nav.click handleTabClick
            nav


        navigationTransition: (fromFrame, toFrame, after) ->
            fromFrame.animateTo 'inactive', null
            toFrame.animateTo 'active', null, after


    # end TabView


    TabView.Frame = class TabFrame extends Lectern.FrameBase


        constructor: (tabView, index, element) ->
            super tabView, index, element, 'inactive'
            this.findLabel()


        findLabel: ->
            label = @element.data 'tab'
            unless label?
                label = $(@container.fetch 'tab', @element)
                if label?
                    label = label.remove().html()
                else
                    label = index.toString()
            @label = label


        setState: (toState, duration, easing, callback) ->
            changed = super
            if changed
                if toState == 'active'
                    @nav.removeClass @settings.classes.inactive
                else
                    @nav.addClass @settings.classes.inactive
            changed


    # end TabFrame


    TabView.NavigateEvent = class TabNavigateEvent extends Lectern.EventBase


        @_eventModes:   ['before', 'after']
        @_eventName:    'Navigate'


        constructor: (@tabView, @fromFrame, @toFrame) ->


    # end TabNavigateEvent


    handleTabClick = (event) ->
        frame = $(event.currentTarget).data('tab-frame')
        frame.container.navigate frame

