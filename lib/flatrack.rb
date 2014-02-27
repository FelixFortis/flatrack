require 'flatrack/version'
require 'active_support/all'
require 'sprockets'
require 'sprockets-sass'
require 'sass'
require 'set'

module Flatrack
  extend ActiveSupport::Autoload

  autoload :Renderer
  autoload :Request
  autoload :Response
  autoload :Site
  autoload :AssetExtensions
  autoload :CLI
  autoload :Cache

  RendererNotFound = Class.new StandardError
  FileNotFound     = Class.new StandardError

  FORMATS = {}

  def self.gem_root
    File.expand_path File.join __FILE__, '..'
  end

  def self.site_root
    @root ||= Dir.pwd
  end

  def self.register_format(ext, mime)
    FORMATS[ext.to_s] = mime
  end

  def self.assets
    @assets ||= begin
      Sprockets::Environment.new.tap do |environment|
        environment.append_path 'assets/images'
        environment.append_path 'assets/javascripts'
        environment.append_path 'assets/stylesheets'
        environment.context_class.class_eval { include AssetExtensions }
      end
    end
  end

  def self.config(&block)
    yield self
  end

  def self.cache_store=(val)
    @cache_store = Array.wrap(val)
    # Only include the middleware when the cache is set
    val ? use(Flatrack::Cache) : middleware.delete([Flatrack::Cache])
    cache
  end

  def self.cache_store
    @cache_store ||= []
  end

  def self.cache_watch_directories
    @cache_watch_directories ||= []
  end

  def self.cache
    @cache ||= ActiveSupport::Cache.lookup_store *cache_store if cache_store.present?
  end

  def self.middleware
    @middleware ||= []
  end

  def self.use(*args)
    self.middleware << args
  end

  self.cache_watch_directories.concat %w{pages layouts helpers}
  I18n.enforce_available_locales = false
  Dir.glob(File.expand_path File.join gem_root, '../renderers/**/*.rb').each { |f| require f }
  Dir.glob(File.expand_path File.join site_root, 'helpers/**/*.rb').each { |f| require f }

end
