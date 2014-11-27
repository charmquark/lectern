%w(coffee-script sass).each {|lib| require lib }

namespace :lectern do

    COMP_CANON_RE   = /coffee\/lectern\.(.*)\.coffee/
    COMP_GLOB       = 'coffee/lectern.*.coffee'


    desc 'make a custom minimized Lectern build with selected components'
    task :customize, [:components] do |task, args|
        compile args.components.split
    end


    desc 'compile an all-components-included build (this also enables the demos)'
    task :everything do
        compile available_components
    end


    desc 'list all available components'
    task :list do
        available_components.each do |canon|
            puts " * #{canon}"
        end
    end


    def available_components
        Dir[COMP_GLOB].map {|comp| comp.match(COMP_CANON_RE)[1] }
    end


    def compile(components)
        puts " * Will be including these components: #{components.join(', ')}"
        puts " * Compiling javascript..."
        compile_js(components);
        puts " * Compiling stylesheet..."
        compile_css(components);
    end


    def compile_css(components)
        template = '@import "lectern.scss";'
        components.each do |comp|
            template += "\n@import 'lectern.#{comp}.scss';"
        end
        sass = Sass::Engine.new template,
            cache: false,
            load_paths: ['./scss'],
            style: :nested,
            syntax: :scss
        IO.write 'build/css/lectern.css', sass.render
        sass.options[:style] = :compact
        IO.write 'build/css/lectern.min.css', sass.render

        sass = Sass::Engine.new IO.read('demo/scss/demo.scss'),
            cache: false,
            load_paths: ['./demo/scss'],
            style: :compact,
            syntax: :scss
        IO.write 'demo/css/demo.css', sass.render
    end


    def compile_js(components)
        # compile core
        compile_js_module '', 'build/js/lectern.js', 'lectern'
        components.each do |comp|
            compile_js_module comp
        end
    end


    def compile_js_module(canon, dest = nil, modfile = nil)
        modfile = "lectern.#{canon}" if modfile.nil?
        src = "coffee/#{modfile}.coffee"
        dest = "build/js/#{modfile}.js" if dest.nil?
        puts " * \t#{src}"
        IO.write dest, CoffeeScript.compile(IO.read(src), bare: true)
    end

end

