class TestJob
  include Sidekiq::Job

  def perform(args)
    ActionCable.server.broadcast(args["websocket_channel"], args["data"])
  end
end
