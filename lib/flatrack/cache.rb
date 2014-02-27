module Flatrack
  class Cache

    def initialize(app)
      @app = app
    end

    def call(env)
      Flatrack.cache.fetch cache_key do
        Flatrack.cache.clear
        @app.call env
      end
    end

    private

    def cache_key
      Digest::SHA2.hexdigest Flatrack.cache_watch_directories.map { |dir| sha dir }.join
    end

    def sha(file)
      if File.directory?(file)
        Dir.chdir(file) do
          Digest::SHA2.hexdigest Dir.glob('*').map { |file| sha file }.join
        end
      else
        File.exists?(file)
        Digest::SHA2.hexdigest File.read file
      end
    end

  end
end