import { z } from "zod";
import { settingsFormSchema } from "./schemas";

type SettingsForm = z.infer<typeof settingsFormSchema>;

export type { SettingsForm };
