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


    namespace :coffee do

        desc 'watch coffee files for changes and autorecompile'
        task :watch do
            `./node_modules/coffee-script/bin/coffee --output build/js/ --compile --watch coffee/*.coffee`
        end

    end


    namespace :demo do

        namespace :scss do

            desc 'watch demo scss files for changes and autorecompile'
            task :watch do
                `scss --watch demo/scss/demo.scss:demo/css/demo.css`
            end

        end

    end


    namespace :scss do

        desc 'watch scss files for changes and autorecompile'
        task :watch do
            `scss --watch scss/lectern.scss:build/css/lectern.css`
        end

    end


    def available_components
        Dir[COMP_GLOB].map {|comp| comp.match(COMP_CANON_RE)[1] }
    end


    def compile(components)
        puts " * Compiling javascript..."
        compile_js(components);
        puts " * Compiling stylesheet..."
        compile_css(components);
    end


    def compile_css(components)
        sass = Sass::Engine.new IO.read('scss/lectern.scss'),
            cache: true,
            load_paths: ['./scss'],
            style: :nested,
            syntax: :scss
        IO.write 'build/css/lectern.css', sass.render
        sass.options[:style] = :compressed
        IO.write 'build/css/lectern.min.css', sass.render

        sass = Sass::Engine.new IO.read('demo/scss/demo.scss'),
            cache: false,
            load_paths: ['./demo/scss'],
            style: :compact,
            syntax: :scss
        IO.write 'demo/css/demo.css', sass.render
    end


    def compile_js(components)
#         # compile core
#         compile_js_module '', 'build/js/lectern.js', 'lectern'
#         components.each do |comp|
#             compile_js_module comp
#         end

        File.unlink 'tmpfile' if File.exists? 'tmpfile'
        tmpfile = File.open 'tmpfile', 'a+'
        IO.copy_stream 'coffee/lectern.coffee', tmpfile
        components.each do |comp|
            puts " * \tincluding: #{comp}"
            IO.copy_stream "coffee/lectern.#{comp}.coffee", tmpfile
        end
        tmpfile.close
        IO.write 'build/js/lectern.js', CoffeeScript.compile(IO.read(tmpfile))
        File.unlink 'tmpfile'
    end


#     def compile_js_module(canon, dest = nil, modfile = nil)
#         modfile = "lectern.#{canon}" if modfile.nil?
#         src = "coffee/#{modfile}.coffee"
#         dest = "build/js/#{modfile}.js" if dest.nil?
#         puts " * \t#{dest}"
#         IO.write dest, CoffeeScript.compile(IO.read(src))
#     end

end

