module Wrappers

  class Heroku
    def self.client
      @@heroku ||= ::Heroku::Client.new(ENV['HEROKU_USER'], ENV['HEROKU_PASS'])
    end

    def self.workers
      client.ps(ENV['HEROKU_APP']).count { |a| a['process'] =~ /worker/ }
    end

    def self.workers=(qty)
      unless workers == qty
        client.ps_scale(ENV['HEROKU_APP'], type: 'worker', qty: qty)
        Rails.logger.info "Scaling to #{qty} worker"
      end
    end
  end

end