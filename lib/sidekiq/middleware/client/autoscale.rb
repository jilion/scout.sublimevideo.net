require 'wrappers/heroku'

module Sidekiq
  module Middleware
    module Client

      class Autoscale
        def call(worker_class, msg, queue)
          yield
          Wrappers::Heroku.workers = 1 unless Wrappers::Heroku.workers == 1
        end
      end

    end
  end
end
