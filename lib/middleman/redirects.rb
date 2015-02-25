require 'middleman-core'
require 'pathname'

module Middleman
  module Redirects
    class Extension < Middleman::Extension
      def initialize(app, options_hash={}, &block)
        app.use ::Middleman::Redirects::Middleware
        ::Middleman::Redirects.redirects_file_path = Pathname.new(app.root).join("REDIRECTS").freeze
        super
      end
    end

    class Middleware
      def initialize(app)
        @app = app
      end

      def call(env)
        source = env['PATH_INFO']
        if destination = ::Middleman::Redirects.redirects[source]
          [302, {"Location" => destination}, []]
        else
          @app.call(env)
        end
      end
    end

    def self.redirects_file_path=(v)
      @redirects_file_path = v
    end

    def self.redirects_file_path
      @redirects_file_path
    end

    def self.redirects
      if self.redirects_file_path.mtime != @mtime
        read_redirects
      else
        @redirects
      end
    end

    def self.read_redirects
      @mtime = self.redirects_file_path.mtime
      @redirects = Hash[self.redirects_file_path.each_line.map do |line|
        next if line =~ /^#/ # ignore comments

        source, destination = line.split.map { |s| URI.parse(s) }

        # don't allow a single / or * as source
        next if source.path == '/'
        next if source.path == '.*'
        next if source.path == '*' # invalid

        [source.to_s, destination.to_s]
      end.compact]
      p @redirects
    end
  end
end

::Middleman::Extensions.register(:redirects, ::Middleman::Redirects::Extension)

require "middleman/redirects/version"
