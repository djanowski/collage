class Collage
  def initialize(app, path)
    @app = app
    @path = File.expand_path(path)
  end

  def call(env)
    return @app.call(env) unless env['PATH_INFO'] == "/#{Collage.filename}"

    result = Packager.new(@path)

    result.ignore(filename)

    File.open(filename, 'w') {|f| f.write(result) }

    [200, {'Content-Type' => 'text/javascript', 'Content-Length' => result.size.to_s, 'Last-Modified' => result.mtime.httpdate}, result]
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
    def initialize(path)
      @path = path
    end

    def package
      files.inject("") do |contents,file|
        contents += File.read(file) + "\n\n"
        contents
      end
    end

    def pattern
      File.join(@path, '**', "*.js")
    end

    def files
      @files ||= Dir[pattern]
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
      result.each(&block)
    end

    def to_s
      result.to_s
    end

    def ignore(file)
      if files.delete(file)
        @result = nil
      end
    end
  end
end
