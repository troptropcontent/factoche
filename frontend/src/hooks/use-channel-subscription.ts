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
    }
  | {
      type: "KpiAverageOrderCompletionGenerated";
      data: number;
    }
  | {
      type: "KpiOrdersDetailsGenerated";
      data: {
        completed_orders_count: number;
        not_completed_orders_count: number;
      };
    }
  | {
      type: "GraphDataMonthlyRevenuesGenerated";
      data: {
        jan?: string | null;
        feb?: string | null;
        mar?: string | null;
        apr?: string | null;
        may?: string | null;
        jun?: string | null;
        jul?: string | null;
        aug?: string | null;
        sep?: string | null;
        oct?: string | null;
        nov?: string | null;
        dec?: string | null;
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
