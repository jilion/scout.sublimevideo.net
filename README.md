## Setup

### (Ultra) Quick setup

```bash
cd $JILION_PATH/Products/SublimeVideo && \
git clone git@github.com:jilion/scout.sublimevideo.net.git && \
jsau && scsv && bi && \
powder link && cd ~/.pow && mv scout.sublimevideo.net scout.sublimevideo && \
scsv

brew install imagemagick # if needed
```

If you have dummy data, you can set all sites to be created on the same day (in the Rails console) to ensure to have nice content:

`Site.all.each { |s| s.update_attribute(:created_at, Time.now.utc) }`

Visit `scout.sublimevideo.dev`!

### Generate dummy screenshots

The app uses the same databases as my.sublimevideo.net so if you have some `Site` records in your database (if not, just run `mysv && dbp`), all you have to do is:

- run `bundle install`;
- be sure the `worker: bundle exec sidekiq -c 5` line in `Procfile` is uncommented (you can also comment the first line to avoid starting the app);
- run `foreman start`.

You can then view the Sidekiq queue at `localhost:5000/sidekiq` (you'll have to log-in as in admin.sublimevideo.net).

## Deploy

```shell
$ heroku config:add PATH=bin:vendor/phantomjs/bin:vendor/bundle/ruby/1.9.1/bin:/usr/local/bin:/usr/bin:/bin LD_LIBRARY_PATH=vendor/phantomjs/lib:/usr/local/lib:/usr/lib:/lib

$ gp production
```