class TestJob
  include Sidekiq::Job

  def perform
    ap "TEST JOB"
  end
end
