require 'wrappers/heroku'

module Sidekiq
  module Middleware
    module Server

      class Autoscale
        def call(worker, msg, queue)
          yield

          if backlog.zero? && !Wrappers::Heroku.workers.zero?
            Wrappers::Heroku.workers = 0
          end
        end

        def backlog
          Sidekiq.options[:queues].sum do |queue|
            Sidekiq::Queue.new(queue).size
          end
        end
      end

    end
  end
end
