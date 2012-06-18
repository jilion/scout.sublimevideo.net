module RecurringJob
  class << self

    def start
      RecurringJob.delay_screenshots_worker
    end

    def delay_screenshots_worker
      ScreenshotsWorker.perform_async
    end

  end
end
