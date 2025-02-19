server:
	bundle exec rails server -b 0.0.0.0 -p 8080 
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
