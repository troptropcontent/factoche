import { useContext, useEffect, useRef, useState } from "react";
import { CableContext } from "@/contexts/cable-context";

type ChannelMessageTypes =
  | {
      type: "PDF_GENERATED";
      data: { record_class: string; record_id: number };
    }
  | {
      type: "KpiTotalRevenueGenerated";
      data: {
        ytd_revenue_for_this_year: string;
        ytd_revenue_for_last_year: string;
      };
    };

export function useChannelSubscription(
  channelName: string,
  onReceive: (data: ChannelMessageTypes) => void
) {
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
