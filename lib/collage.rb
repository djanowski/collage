class Collage
  def initialize(app, options)
    @app = app
    @path = File.expand_path(options[:path])
    @files = options[:files]
  end

  def call(env)
    return @app.call(env) unless env['PATH_INFO'] == "/#{Collage.filename}"

    result = Packager.new(@path, @files)

    result.ignore(filename)

    File.open(filename, 'w') {|f| f.write(result) }

    [200, {'Content-Type' => 'text/javascript', 'Content-Length' => result.size.to_s, 'Last-Modified' => File.mtime(filename).httpdate}, result]
  end

  def filename
    File.join(@path, Collage.filename)
  end

  class << self
    def filename
      "js.js"
    end

    def timestamp(path)
      Packager.new(path).timestamp
    end

    def html_tag(path)
      %Q{<script type="text/javascript" src="/#{filename}?#{timestamp(path)}"></script>}
    end
  end

  class Packager
    def initialize(path, patterns = nil)
      @path = path
      @patterns = Array(patterns || "**/*.js")
    end

    def package
      files.inject("") do |contents,file|
        contents += package_file(file) + "\n\n"
        contents
      end
    end

    def package_file(file)
      File.read(file)
    end

    def files
      @files ||= @patterns.map do |pattern|
        File.exist?(pattern) ? pattern : Dir[File.join(@path, pattern)]
      end.flatten.uniq
    end

    def timestamp
      mtime.to_i.to_s
    end

    def mtime
      @mtime ||= files.map {|f| File.mtime(f) }.max
    end

    def size
      result.size
    end

    def result
      @result ||= package
    end

    def each(&block)
      result.each_line(&block)
    end

    def to_s
      result.to_s
    end

    def inspect
      "#<Collage::Packager (#{size} files)>"
    end

    def ignore(file)
      if files.delete(file)
        @result = nil
      end
    end

    def write(path, minify = false)
      contents = minify ? self.minify : result

      File.open(path, "w") do |f|
        f.write(contents.to_s)
      end

      FileUtils.touch(path, :mtime => mtime)
    end

    COMPRESSOR = File.expand_path("../vendor/yuicompressor-2.4.2.jar", File.dirname(__FILE__))

    def minify
      minified = IO.popen("java -jar #{COMPRESSOR} --type #{type}", "r+") do |io|
        io.write(result.to_s)
        io.close_write
        io.read
      end

      $?.success? or raise RuntimeError.new("Error minifying #{files.inspect}.")

      minified
    end

    def type
      :js
    end

    class Sass < self
      def package_file(file)
        contents = render(file)

        inject_timestamps(contents)
      end

      def type
        :css
      end

    protected
      def inject_timestamps(css)
        css.gsub(/(url\(\"?)(.+?)(\"?\))/) do
          path = File.join(@path, $2)
          stamp = "?#{File.mtime(File.join(@path, $2)).to_i}" if File.exist?(path)

          "#{$1}#{$2}#{stamp}#{$3}"
        end
      end

      def render(file)
        contents = File.read(file)

        extension = File.extname(file)[1..-1]

        case extension
          when "sass", "scss"
            contents = ::Sass::Engine.new(contents, syntax: extension.to_sym).render
        end

        contents
      end
    end
  end
end
