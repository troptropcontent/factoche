server:
	rm -f tmp/pids/server.pid && bundle exec dotenv -f config/.env.development rails server -p 8080
rails:
	bundle exec dotenv -f config/.env.development rails $(ARGS)
deploy:
	bundle exec dotenv -f config/.env.production kamal deploy -d production
boot_chromium:
	bundle exec dotenv -f config/.env.production kamal accessory boot -d production chromium
production:
	bundle exec dotenv -f config/.env.production kamal app exec -d production -r web -i --reuse "bin/rails console"
rswag:
	bundle exec dotenv -f config/.env.development rails rswag:specs:swaggerize PATTERN="spec/controllers/**/*_spec.rb"
rspecf:
	bundle exec dotenv -f config/.env.development rspec --tag focus
migration:
	bundle exec dotenv -f config/.env.development rails g migration $(filter-out $@,$(MAKECMDGOALS))
migrate:
	bundle exec dotenv -f config/.env.development rails db:migrate
rollback:
	bundle exec dotenv -f config/.env.development rails db:rollback
routesc:
	bundle exec dotenv -f config/.env.development rails routes -c $(filter-out $@,$(MAKECMDGOALS))
rspec:
	bundle exec dotenv -f config/.env.development rspec $(filter-out $@,$(MAKECMDGOALS))
frontend:
	(cd ../frontend && pnpm run dev)
tailwindcss:
	pnpm exec tailwindcss -i app/assets/tailwind/input.css -o app/assets/tailwind/output.css --watch
guard:
	bundle exec dotenv -f config/.env.development guard
sidekiq:
	bundle exec dotenv -f config/.env.development sidekiq
console:
	bundle exec dotenv -f config/.env.development rails console
seed:
	bundle exec dotenv -f config/.env.development rails db:seed
reset:
	bundle exec dotenv -f config/.env.development rails db:reset
flush_sidekiq:
	bundle exec dotenv -f config/.env.development rails runner "Sidekiq.redis(&:flushdb)"
