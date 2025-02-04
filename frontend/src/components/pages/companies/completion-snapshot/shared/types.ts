type CompletionSnapshotItem = {
  item_id: number;
  completion_percentage: string;
};

type CompletionSnapshot = {
  id: number;
  created_at: string;
  completion_snapshot_items: Array<CompletionSnapshotItem>;
};

export type { CompletionSnapshotItem, CompletionSnapshot };
