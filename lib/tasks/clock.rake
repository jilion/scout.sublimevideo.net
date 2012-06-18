namespace :clock do
  desc "Take new screenshots"
  task screenshots: :environment do
    puts "Delaying ScreenshotsWorker#perform"
    ScreenshotsWorker.perform_async
  end
end
