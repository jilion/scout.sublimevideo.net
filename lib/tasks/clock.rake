namespace :clock do
  desc "Take new screenshots"
  task screenshots: :environment do
    puts "Restarting worker if needed"
    search = JSON[`curl -s -H "X-Papertrail-Token: #{ENV['PAPERTRAIL_API_TOKEN']}" "https://papertrailapp.com/api/v1/events/search.json?q='R14'"`]
    if last_event = search['events'].last
      Wrappers::Heroku.restart_workers if Time.parse(last_event['received_at']) > 1.hour.ago
    end
    puts "Delaying ScreenshotsWorker#perform"
    ScreenshotsWorker.perform_async
  end
end
