import { CableContext } from "@/contexts/cable-context";
import { Subscription } from "@rails/actioncable";
import { useContext, useEffect, useRef } from "react";

type ChannelMessageTypes = {
  type: "PDF_GENERATED";
  data: { record_class: string; record_id: number };
};

const useChannelSubscription = ({
  channelName,
  onReceive,
}: {
  channelName: string;
  onReceive: (message: ChannelMessageTypes) => void;
}) => {
  const { cable } = useContext(CableContext);
  const subscriptionRef = useRef<Subscription | null>(null);

  useEffect(() => {
    if (!cable) {
      throw new Error("Cable is not initialized.");
    }

    const subscription = cable.subscriptions.create(
      { channel: channelName },
      {
        received: onReceive,
        connected: () => console.log(`[Cable] Connected to ${channelName}`),
        disconnected: () =>
          console.log(`[Cable] Disconnected from ${channelName}`),
        rejected: () =>
          console.warn(`[Cable] Rejected subscription to ${channelName}`),
      }
    );

    subscriptionRef.current = subscription;

    return () => {
      subscription?.unsubscribe();
    };
  }, [cable, channelName, onReceive]);
};

export { useChannelSubscription };
