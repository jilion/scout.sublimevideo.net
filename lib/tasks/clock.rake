namespace :clock do
  desc "Take new screenshots"
  task screenshots: :environment do
    Rails.logger.info "Delaying ScreenshotsWorker#perform"
    ScreenshotsWorker.perform_async
  end

  desc "Restart workers if needed"
  task supervise_workers: :environment do
    Rails.logger.info "Restarting worker if needed"
    search = JSON[`curl -s -H "X-Papertrail-Token: #{ENV['PAPERTRAIL_API_TOKEN']}" "https://papertrailapp.com/api/v1/events/search.json?q='R14'"`]
    if last_event = search['events'].last and Time.parse(last_event['received_at']) > 10.minutes.ago
      Rails.logger.info "Restart workers!!!!!!"
      Wrappers::Heroku.restart_workers
    end
  end
end
