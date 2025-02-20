# frozen_string_literal: true

require 'json'

require 'rack/idempotency/version'

require 'rack/idempotency/errors'
require 'rack/idempotency/store/base'
require 'rack/idempotency/store/memory'
require 'rack/idempotency/store/null'
# require 'rack/idempotency/store/redis'
require 'rack/idempotency/request'
require 'rack/idempotency/request_storage'
require 'rack/idempotency/response'

module Rack
  # Rack middleware for ensuring mutating endpoints are called at most once.
  #
  # Any request with an `Idempotency-Key` header will store its response in
  # the given cache.  When the client retries, it will get the previously
  # cached response.
  class Idempotency
    def initialize(app, store: Store::Null.new)
      @app     = app
      @store   = store
    end

    def call(env)
      request = Request.new(env.dup)
      storage = RequestStorage.new(@store, request)

      storage.read || store_response(storage, env)
    end

    private

    def store_response(storage, env)
      response = Response.new(*@app.call(env))

      storage.write(response)

      response.to_a
    end
  end
end
