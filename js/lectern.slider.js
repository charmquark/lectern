(function($) {
    var self = {
        auto_queue: '[data-lectern-slider]',
        canon: 'slider',
        default_action: 'create',
        name: 'Slider',

        defaults: {
            classes: {
                active: 'lectern-slider-active',
                canvas: 'lectern-slider-canvas',
                caption: 'lectern-slider-caption',
                container: 'lectern-slider-container',
                hidden1: 'lectern-slider-hidden1',
                hidden2: 'lectern-slider-hidden2',
                navigator: 'lectern-slider-navigator',
                slide: 'lectern-slider-slide',
            },

            queries: {
                canvas: '> ul',
                caption: '> span',
                slides: '> li'
            },

            states: {
                active: {
                    opacity: 1.0,
                    left: '0px',
                    right: '0px'
                },
                hidden1: {
                    opacity: 0.0,
                    left: '100%',
                    right: '-100%'
                },
                hidden2: {
                    opacity: 0.0,
                    left: '-100%',
                    right: '100%'
                }
            },

            duration: 500,
            easing: 'swing',
            indexClasses: false,
            wrapAround: true
        },

        actions: {
            active: function() {
                var result = $();
                this.each(function(idx, container) {
                    result = result.add(data($(container)).active);
                });
                return result;
            },

            create: function(options) {
                this.each(function(idx, container) {
                    container = $(container);
                    var settings = get_settings(container, options);
                    var slider = {
                        container: container,
                        settings: settings
                    };
                    container.addClass(settings.classes.container);

                    slider.caption = 
                        $(settings.queries.caption, container)
                        .addClass(settings.classes.caption)
                    ;

                    slider.canvas =
                        $(settings.queries.canvas, container)
                        .addClass(settings.classes.canvas)
                    ;

                    slider.slides = Lectern.util.add_classes(
                        slider,
                        $(settings.queries.slides, slider.canvas),
                        ['slide', 'hidden1']
                    );

                    if (settings.indexClasses) {
                        slider.slides.each(function(idx, elt) {
                            $(elt).addClass('slide-' + idx);
                        });
                    }

                    generate_navigator(slider);

                    slider.active = slider.slides.first()
                        .removeClass(settings.classes.hidden1)
                        .addClass(settings.classes.active)
                    ;
                    animate_to(slider.active, 'active', settings);

                    data(container, slider);
                });
                return this;
            },

            next: function() {
                this.each(function(i, elt) {
                    var slider = data($(elt));
                    var active = slider.active;
                    var slides = slider.slides;
                    if (active != slides.last()) {
                        navigate($(slides.get(data(active).index + 1)));
                    }
                    else if (slider.settings.wrapAround) {
                        navigate(slides.first());
                    }
                });
            },

            prev: function() {
                this.each(function(i, elt) {
                    var slider = data($(elt));
                    var active = slider.active;
                    var slides = slider.slides;
                    if (active != slides.first()) {
                        navigate($(slides.get(data(active).index - 1)));
                    }
                    else if (slider.settings.wrapAround) {
                        navigate(slides.last());
                    }
                });
            }
        }
    };


    function animate_to(slide, to_state, settings) {
        slide.animate(
            settings.states[to_state],
            settings.duration,
            settings.easing
        );
        set_slide_state(slide, to_state);
        return slide;
    }


    var data = Lectern.generate.data_func(self.canon);


    function generate_navigator(slider) {
        var nav =
            $('<ul></ul>')
            .addClass(slider.settings.classes.navigator)
        ;
        slider.slides.each(function(idx, elt) {
            elt = $(elt);
            var li = 
                data($('<li></li>'),{
                    index: idx,
                    slide: elt
                })
                .click(on_navigator_click)
            ;
            nav.append(li);
            data(elt, {
                index: idx,
                nav: li,
                slider: slider,
                state: 'hidden1'
            });
        });
        nav.children().first().addClass(slider.settings.classes.active);
        slider.container.append(slider.navigator = nav);
        return nav;
    }


    var get_settings = Lectern.generate.get_settings_func(
        self.defaults,
        ['duration', 'easing', 'indexClasses', 'wrapAround']
    );


    function navigate(new_slide) {
        var new_slide_data = data(new_slide);
        var slider = new_slide_data.slider;
        var old_slide = slider.active;
        animate_to(old_slide, new_slide_data.index > data(old_slide).index ? 'hidden2' : 'hidden1', slider.settings);
        slider.active = animate_to(new_slide, 'active', slider.settings);
    }


    function on_navigator_click(event) {
        navigate(data($(event.target)).slide);
    }


    function set_slide_state(slide, to_state) {
        var slide_data = data(slide);
        if (slide_data.state != to_state) {
            var settings = slide_data.slider.settings;
            if (slide_data.state == 'active') {
                slide_data.nav.removeClass(settings.classes.active);
            }
            if (to_state == 'active') {
                slide_data.nav.addClass(settings.classes.active);
            }
            slide
                .removeClass(settings.classes[slide_data.state])
                .addClass(settings.classes[to_state])
            ;
            slide_data.state = to_state;
        }
        return slide;
    }


    Lectern.add_component(self);
})(jQuery);
