server:
	bundle exec rails server
rswag:
	bundle exec rails rswag:specs:swaggerize PATTERN="spec/controllers/**/*_spec.rb"
rspecf:
	bundle exec rspec --tag focus
rspec:
	bundle exec rspec

frontend:
	(cd ../frontend && pnpm run dev)
tailwind:
	pnpm exec tailwindcss -i app/assets/tailwind/input.css -o app/assets/tailwind/output.css --watch