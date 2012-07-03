require 'wrappers/heroku'

module Sidekiq
  module Middleware
    module Client

      class Autoscale
        def call(worker_class, item, queue)
          yield
          Wrappers::Heroku.workers = 1
        end
      end

    end
  end
end