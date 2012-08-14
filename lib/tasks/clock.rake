namespace :clock do
  desc "Take new screenshots"
  task screenshots: :environment do
    puts "Retarting worker if needed"
    search = JSON[`curl -v -H "X-Papertrail-Token: #{ENV['PAPERTRAIL_API_TOKEN']}" "https://papertrailapp.com/api/v1/events/search.json?q='R14'" 1&2>/dev/null`]
    Wrappers::Heroku.restart_workers if Time.parse(search['events'].last['received_at']) > 1.hour.ago

    puts "Delaying ScreenshotsWorker#perform"
    ScreenshotsWorker.perform_async
  end
end
