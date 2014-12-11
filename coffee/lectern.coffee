Lectern = window.Lectern =

    components: {}
    version:    '0.2.0'


    defaults:
        ignoreData: false


    addComponent: (component) ->
        Lectern.components[component._canon] = Lectern[component.name] = component
        component._defaults = {} unless component._defaults?
        this


    initiate: ->
        for canon of Lectern.components
            $("[data-lectern-#{canon}]").lectern(canon)
        this


    invoke: (element, canon, options) ->
        component = Lectern.components[canon]
        if component?
            settings = $.extend true, {}, Lectern.defaults, component._defaults, options
            unless settings.ignoreData or not component._dataAttrOptions?
                for key in component._dataAttrOptions
                    value = element.data key
                    settings[key] = value if value?
            element.data 'lectern-' + canon, new component element, settings
        this


    ComponentBase: class LecternComponentBase

        constructor: (@element, @settings)->
            @events = {}
            element.addClass settings.classes.container if settings.classes.container?

        addClass: (name, elt) ->
            elt = @element unless elt?
            elt.addClass @settings.classes[name]


        addClasses: (names, elt) ->
            elt = @element unless elt?
            classes = this.classes names
            elt.addClass classes.join ' '


        addEvent: (eventClass) ->
            name = eventClass._eventName
            for mode in eventClass._eventModes
                tag = mode + name
                @events[tag] = meta =
                    eventClass: eventClass
                    factory:    factoryFor eventClass
                    handlers:   []
                    tag:        tag

                    fire: () ->
                        event = this.factory arguments
                        for h in @handlers
                            h.callback(event, h.eventData)
                        null

                do (meta) =>
                    this[meta.tag] = (handler, eventData) =>
                        meta.handlers.push
                            callback:   handler
                            eventData:  eventData
                        this
            this


        classes: (names) ->
            available = @settings.classes
            if available?
                for n in names
                    available[n]
            else
                []


        classyFetch: (selector, elt) ->
            this.fetch selector, elt
                .addClass @settings.classes[selector]


        fetch: (selector, elt) ->
            $(@settings.queries[selector], if elt? then elt else @element)


        removeClasses: (names, elt) ->
            elt = @element unless elt?
            classes = this.classes names
            elt.removeClass classes.join ' '


        swapClasses: (from, to, elt) ->
            elt = @element unless elt?
            this.removeClasses from, elt
            this.addClasses to, elt


    # end ComponentBase


    EventBase: class LecternEventBase


        constructor: ->


    # end EventBase


    FrameBase: class LecternFrameBase


        constructor: (@container, @index, @element, @state) ->
            @nav        = null
            @settings   = settings = container.settings

            if settings.indexClasses
                element.addClass "frame-#{index}"

            element.css settings.states[state]


        animateTo: (toState, fromState, callback) ->
            if fromState? and @state != fromState
                this.setState fromState, 0
            this.setState toState, @settings.duration, @settings.easing, callback


        setState: (toState, duration, easing, callback) ->
            unless @state == toState
                settings    = @settings
                element     = @element
                fromState   = @state
                container   = @container

                if duration > 0
                    element.animate settings.states[toState], duration, easing, ->
                        container.swapClasses [fromState], [toState], element
                        callback() if callback?
                else
                    container.swapClasses   [fromState], [toState], element
                             .css           settings.states[toState]
                    callback() if callback?

                @nav.removeClass    settings.classes.active if fromState == 'active'
                @nav.addClass       settings.classes.active if toState   == 'active'

                @state = toState
                true
            else
                false


    # end FrameBase


    FrameCanvasComponentBase: class LecternFrameCanvasComponentBase extends LecternComponentBase


        constructor: (element, settings, FrameClass, NavEvent) ->
            super element, settings

            @busy   = false
            @canvas = this.classyFetch 'canvas'
            @queue  = []

            frameElements = @canvas.children()
            this.addClass 'frame', frameElements
            frameFactory = factoryFor FrameClass
            @frames = frames = (frameFactory(this, idx, $(elt)) for elt, idx in frameElements)

            @first = frames[0]
            @last = frames[frames.length - 1]
            @active = frames[0]

            this.generateNavigator()
            @active.setState 'active', 0

            this.addEvent NavEvent


        generateNavigator: (tag, nodeClasses)->
            unless @navigator?
                nav = $ '<ul></ul>'
                    .addClass @settings.classes.navigator

                for frame in @frames
                    node = $ '<li></li>'
                    this.addClasses nodeClasses, node if nodeClasses?
                    if @settings.indexClasses
                        node.addClass "#{tag}-#{frame.index}"
                    node.data "#{tag}-frame", frame
                    frame.nav = node
                    nav.append node

                @navigator = nav
            else
                null


        navigate: (toFrame) ->
            @queue.push toFrame
            unless @busy
                @busy = true
                this.processQueue()
            this


        processQueue: ->
            queue = @queue
            if queue.length != 0
                toFrame = queue.shift()
                if $.type(toFrame) == 'number'
                    toFrame = @frames[toFrame]
                active = @active
                unless toFrame == active
                    @events.beforeNavigate.fire this, active, toFrame

                    after = =>
                        @events.afterNavigate.fire this, active, toFrame
                        this.processQueue()

                    this.navigationTransition(active, toFrame, after)
                    @active = toFrame
            else
                @busy = false
            null


        navigationTransition: (fromFrame, toFrame, after) ->


    # end FrameCanvasComponentBase


# end Lectern


factoryFor = (type) ->
    F = (args)-> type.apply this, args
    F.prototype = type.prototype
    return ()->
        new F arguments


$.fn.dataElse = (key, alt) ->
    result = this.data key
    if result? and result != ''
        result
    else if $.type(alt) == 'function'
        alt(this, key)
    else
        alt


$.fn.lectern = (canon, options) ->
    if $.type(canon) == 'string'
        for elt in this
            elt = $ elt
            elt.dataElse 'lectern-' + canon, -> Lectern.invoke elt, canon, options
    else
        throw 'invalid arguments to .lectern(...)'
    this

