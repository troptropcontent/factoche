class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_from current_company.websocket_channel
  end
end
