module Sidekiq
  module Middleware
    module Client

      class UniqueJob
        HASH_KEY_EXPIRATION = 60 * 60 # 1 hour

        def call(worker_class, msg, queue)
          payload_hash = Digest::MD5.hexdigest(MultiJson.encode(msg))
          Sidekiq.redis do |redis|
            return if redis.get(payload_hash)
            redis.setex(payload_hash, HASH_KEY_EXPIRATION, 1)
          end

          yield
        end
      end

    end
  end
end
