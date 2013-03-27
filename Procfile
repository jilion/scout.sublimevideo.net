web:    bundle exec rails server thin -p $PORT
worker: DB_POOL=7 bundle exec sidekiq -C config/sidekiq_cli.yml
