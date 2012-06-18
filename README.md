## Setup

### (Ultra) Quick setup

```bash
cd $JILION_PATH/Products/SublimeVideo \
&& git clone git@github.com:jilion/scout.sublimevideo.net.git \
&& jsau && scsv && bi \
&& powder link && cd ~/.pow && mv scout.sublimevideo.net scout.sublimevideo \
&& scsv
```

Visit `scout.sublimevideo.dev`!

### Generate dummy screenshots

The app uses the same databases as my.sublimevideo.net so if you have some `Site` records in your database (if not, just run `mysv && dbp`), all you have to do is:

- run `bundle install`;
- be sure the `worker: bundle exec sidekiq -c 5` line in `Procfile` is uncommented;
- run `foreman start`.

You can then view the Sidekiq queue at `localhost:5000/sidekiq` (you'll have to log-in as in admin.sublimevideo.net).
