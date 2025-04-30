module Organization
  module Dashboards
    module Broadcastable
      extend ActiveSupport::Concern

      def broadcast_to_channel(websocket_channel_id, data, websocket_notification_key: nil)
        if websocket_notification_key == nil
          is_const_defined = self.class.const_defined?("WEB_SOCKET_NOTIFICATION_KEY")
          unless is_const_defined
            raise Error::UnprocessableEntityError, "if the websocket_notification_key option is not provided as an argument, WEB_SOCKET_NOTIFICATION_KEY must be defined in a class constant"
          end
          websocket_notification_key = self.class.const_get("WEB_SOCKET_NOTIFICATION_KEY")
        end
        ActionCable.server.broadcast(
          websocket_channel_id,
          {
            "type" => websocket_notification_key,
            "data" => data
          }
        )
      end
    end
  end
end
