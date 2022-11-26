# frozen_string_literal: true

require 'openssl/hmac'

module Rack
  class Idempotency
    class RequestStorage
      def initialize(store, request)
        @store   = store
        @request = request
      end

      def read
        return if request.idempotency_key.nil?

        stored = store.read(key)
        store.deserialize(stored) if stored
      end

      def write(response)
        return if request.idempotency_key.nil?

        store.write(key, store.serialize(response))
      end

      private

      attr_reader :request, :store

      def key
        @key ||= "idempotency:#{digest}"
      end

      def digest
        digestable = "#{request.idempotency_key}:#{request.url}:#{request.params}"
        OpenSSL::HMAC.hexdigest('SHA256', 'idempotency', digestable)
      end
    end
  end
end
