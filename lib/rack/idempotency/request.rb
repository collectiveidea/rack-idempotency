# frozen_string_literal: true

require 'rack/request'

module Rack
  class Idempotency    
    class Request < Rack::Request
      def idempotency_key
        get_header('HTTP_IDEMPOTENCY_KEY').tap do |key|
          unless key.nil? || key.length <= 255
            raise IdempotencyKeyTooLong.new(env), 'Idempotency-Key must be less than 256 characters long'
          end
        end
      end
    end
  end
end
