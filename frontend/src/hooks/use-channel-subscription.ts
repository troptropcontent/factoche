import { useContext, useEffect, useRef, useState } from "react";
import { CableContext } from "@/contexts/cable-context";

export function useChannelSubscription<
  T extends { type: string; data: unknown },
>(channelName: string, onReceive: (data: T) => void) {
  const { cable } = useContext(CableContext);
  const subscriptionRef = useRef<ActionCable.Subscription | null>(null);
  const [connected, setConnected] = useState(false);

  useEffect(() => {
    if (!cable) throw new Error("Cable not connected");

    const subscription = cable.subscriptions.create(
      { channel: channelName },
      {
        connected: () => {
          console.log(`[Cable] Connected to ${channelName}`);
          setConnected(true);
        },
        disconnected: () => {
          console.log(`[Cable] Disconnected from ${channelName}`);
          setConnected(false);
        },
        received: onReceive,
        rejected: () => {
          console.warn(`[Cable] Rejected subscription to ${channelName}`);
        },
      }
    );

    subscriptionRef.current = subscription;

    return () => {
      subscription.unsubscribe();
    };
  }, [cable, channelName, onReceive]);

  return connected;
}
