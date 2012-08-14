require 'heroku-api'

module Wrappers

  class Heroku
    def self.client
      @@heroku ||= ::Heroku::API.new(api_key: ENV['HEROKU_API_KEY'])
    end

    def self.workers
      client.get_ps(ENV['HEROKU_APP']).body.count { |a| a['process'] =~ /worker/ }
    end

    def self.workers=(qty)
      unless workers == qty
        Rails.logger.info "Scaling to #{qty} worker"
        client.post_ps_scale(ENV['HEROKU_APP'], 'worker', qty)
      end
    end

    def self.restart_workers
      Rails.logger.info "Restarting worker.1"
      client.post_ps_restart(ENV['HEROKU_APP'], 'ps' => 'worker.1')
    end
  end

end
