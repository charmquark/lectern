(function($) {
    var self = {
        auto_queue: '[data-lectern-slider]',
        canon: 'slider',
        default_action: 'create',
        name: 'Slider',

        defaults: {
            classes: {
                active: 'lectern-slider-active',
                base: 'lectern-slider-base',
                canvas: 'lectern-slider-canvas',
                caption: 'lectern-slider-caption',
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
            create: function(options) {
                var slider = {
                    base: this,
                    settings: $.extend(true, {}, self.defaults, options)
                };
                slider.base.addClass(slider.settings.classes.base);
                slider.caption = 
                    $(slider.settings.queries.caption, this)
                    .addClass(slider.settings.classes.caption)
                ;
                slider.canvas =
                    $(slider.settings.queries.canvas, this)
                    .addClass(slider.settings.classes.canvas)
                ;
                slider.slides =
                    $(slider.settings.queries.slides, slider.canvas)
                    .addClass([
                        slider.settings.classes.slide,
                        slider.settings.classes.hidden1
                    ].join(' '))
                ;
                if (slider.settings.indexClasses) {
                    slider.slides.each(function(idx, elt) {
                        $(elt).addClass('slide-' + idx);
                    });
                }

                generate_navigator(slider);

                slider.active = slider.slides.first()
                    .removeClass(slider.settings.classes.hidden1)
                    .addClass(slider.settings.classes.active)
                ;
                animate_to(slider.active, 'active', slider.settings);

                data(this, slider);
                return this;
            },

            next: function() {
                this.each(function(i, elt) {
                    var slider = data($(elt));
                    if (slider.active != slider.slides.last()) {
                        navigate($(slider.slides.get(data(slider.active).index + 1)));
                    }
                    else if (slider.settings.wrapAround) {
                        navigate(slider.slides.first());
                    }
                });
            },

            prev: function() {
                this.each(function(i, elt) {
                    var slider = data($(elt));
                    if (slider.active != slider.slides.first()) {
                        navigate($(slider.slides.get(data(slider.active).index - 1)));
                    }
                    else if (slider.settings.wrapAround) {
                        navigate(slider.slides.last());
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


    function data(element, arg) {
        if (arg === undefined) {
            return element.data('lectern-slider');
        }
        else {
            return element.data('lectern-slider', arg);
        }
    }


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
        slider.base.append(slider.navigator = nav);
        return nav;
    }


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
