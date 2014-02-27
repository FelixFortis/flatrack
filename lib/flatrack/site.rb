module Flatrack

  register_format :html, 'text/html'

  Site = Rack::Builder.app do

    # Static Assets Should be served directly
    # use Rack::Static, urls: ["/favicon.ico", "assets"], root: "public"

    # Sprockets has its own internal caching mechanism, so lets not leverage flat racks cache.

    Flatrack.middleware.each do |middleware|
      use *middleware
    end

    map '/assets' do
      run Flatrack.assets
    end

    map '/' do
      run ->(env){ Request.new(env).response }
    end
  end
end