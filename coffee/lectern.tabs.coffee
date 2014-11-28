do ->

    self = 

        autoQueue:      '[data-lectern-tabs]'
        canon:          'tabs'
        defaultAction:  'create'
        name:           'Tabs'


        defaults:
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
                frames:     '> ul > li'
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


        actions:
            create: (options) ->
                this.each (idx, container) ->
                    new TabView $(container), options
                this


    class Frame

        constructor: (@tabView, @index, @element) ->
            data element, this

            @tab        = null
            @settings   = tabView.settings
            @state      = ''

            element.addClass @settings.classes.frame
            if @settings.indexClasses
                element.addClass 'frame-' + @index


        animateTo: (toState) ->
            this.setState toState, @settings.duration, @settings.easing


        jumpTo: (toState) ->
            this.setState toState, 0, 'linear'


        setState: (toState, duration, easing) ->
            unless @state == toState
                @element.animate @settings.states[toState], duration, easing

                activeClass     = @settings.classes.active
                inactiveClass   = @settings.classes.inactive

                if toState == 'active'
                    remove  = inactiveClass
                    add     = activeClass
                else
                    remove  = activeClass
                    add     = inactiveClass

                @tab.add @element
                    .removeClass remove
                    .addClass add

                @state = toState
            this

    # end Frame


    self.TabView = class TabView extends Lectern.base.ComponentMain

        constructor: (container, options) ->
            super container, getSettings(container, options)
            data container, this

            @canvas = this.classyFetch 'canvas'
            @frames = (new Frame(this, idx, $(elt)) for elt, idx in this.fetch 'frames')
            @tabBar = generateTabBar this
            @active = @frames[0]

            container.addClass @settings.classes.container
            container.prepend @tabBar

            height = findFrameHeight @settings.height, @frames
            container.height height + @tabBar.outerHeight()
            @canvas.height height
            for f in @frames
                f.element.css
                    'max-height': @canvas.innerHeight()
                f.jumpTo 'inactive'
            @active.jumpTo 'active'


        navigate: (toFrame) ->
            if $.type(toFrame) == 'number'
                toFrame = @frames[toFrame]
            unless @active == toFrame
                @active.animateTo 'inactive'
                @active = toFrame.animateTo 'active'


    # end TabView


    data = Lectern.generators.data self.canon


    findFrameHeight = (opt, frames) ->
        return opt if opt?
        height = 0
        for f in frames
            fh = f.element.outerHeight()
            height = fh if fh > height
        height


    generateTabBar = (tabView) ->
        settings = tabView.settings
        bar = $ '<ul></ul>'
            .addClass settings.classes.tabBar

        for frame in tabView.frames
            label = frame.element.data 'tab'
            unless label?
                label = $(settings.queries.tab, frame.element)
                if label?
                    label = label.remove().html()
                else
                    label = frame.index.toString()
            tab = $ '<li></li>'
                .addClass   settings.classes.tab
                .html       label
                .click      onTabClick

            if settings.indexClasses
                tab.addClass 'tab-' + frame.index

            data tab, frame
            frame.tab = tab
            bar.append tab

        bar


    getSettings = Lectern.generators.getSettings self.defaults, [
        'duration', 'easing', 'height', 'indexClasses'
    ]


    onTabClick = (event) ->
        frame = data $(event.currentTarget)
        frame.tabView.navigate frame


    Lectern.addComponent self
