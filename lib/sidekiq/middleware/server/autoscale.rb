require 'wrappers/heroku'

module Sidekiq
  module Middleware
    module Server

      class Autoscale
        def call(worker, msg, queue)
          yield
          Wrappers::Heroku.workers = 0 if backlog.zero? && workers.one? && workers.first == worker
        end

        def backlog
          Sidekiq.redis do |conn|
            conn.smembers('queues').inject(0) { |sum, q| sum += conn.llen("queue:#{q}") || 0 }
          end
        end

        def workers
          Sidekiq.redis { |conn| conn.smembers('workers') }
        end
      end

    end
  end
end
