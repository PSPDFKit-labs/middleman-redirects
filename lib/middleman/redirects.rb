require 'middleman-core'
require 'pathname'

module Middleman
  module Redirects
    BLANK_RE = /\A[[:space:]]*\z/

    class Extension < Middleman::Extension
      option :match_trailing_slashes, true, 'match source URI even when requested with a trailing slash'

      def initialize(app, options_hash={}, &block)
        super
        app.use ::Middleman::Redirects::Middleware
        ::Middleman::Redirects.match_trailing_slashes = options.match_trailing_slashes
        ::Middleman::Redirects.redirects_file_path = Pathname.new(app.root).join("REDIRECTS").freeze
      end
    end

    class Middleware
      def initialize(app)
        @app = app
      end

      def call(env)
        source = env['PATH_INFO']
        destination, redirect_code = ::Middleman::Redirects.redirects[source]

        return @app.call(env) unless destination

        [redirect_code, {"Location" => destination}, []]
      end
    end

    class << self
      attr_accessor :match_trailing_slashes
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
      @redirects = {}

      self.redirects_file_path.each_line.map do |line|
        next if line =~ /^#/ # ignore comments
        next if line.empty?
        next if BLANK_RE === line

        parts = line.split
        source = URI.parse(parts[0])
        destination = URI.parse(parts[1])
        redirect_code = if parts[2] =~ /permanent/
                          301
                        else
                          302
                        end

        # don't allow a single / or * as source
        next if source.path == '/'
        next if source.path == '.*'
        next if source.path == '*' # invalid

        @redirects[source.to_s] = [destination.to_s, redirect_code]
      end

      autogenerated_redirects = {}

      # duplicate redirect so it also matches URIs with a trailing slash
      if self.match_trailing_slashes
        @redirects.each do |source, destination_and_code|
          next if source[-1] == '/'
          autogenerated_redirects["#{source}/"] = destination_and_code
        end
      end

      @redirects.merge!(autogenerated_redirects)
    end
  end
end

::Middleman::Extensions.register(:redirects, ::Middleman::Redirects::Extension)

require "middleman/redirects/version"
