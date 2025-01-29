import { z } from "zod";

const completionSnapshotFormSchema = z.object({
  description: z.string().nullable(),
  completion_snapshot_attributes: z.array(
    z.object({ item_id: z.number(), completion_percentage: z.string() })
  ),
});

export { completionSnapshotFormSchema };
