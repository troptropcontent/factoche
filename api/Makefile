server:
	rm -f tmp/pids/server.pid && bundle exec rails server -p 8080
deploy:
	bundle exec dotenv -f config/.env.production kamal deploy -d production
rswag:
	bundle exec rails rswag:specs:swaggerize PATTERN="spec/controllers/**/*_spec.rb"
rspecf:
	bundle exec rspec --tag focus
rspec:
	bundle exec rspec
frontend:
	(cd ../frontend && pnpm run dev)
tailwindcss:
	pnpm exec tailwindcss -i app/assets/tailwind/input.css -o app/assets/tailwind/output.css --watch
guard:
	bundle exec guard
sidekiq:
	bundle exec sidekiq
console:
	bundle exec rails console
