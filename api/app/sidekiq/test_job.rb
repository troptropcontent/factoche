class TestJob
  include Sidekiq::Job

  def perform(args)
    ap "COUCOU"
  end
end
