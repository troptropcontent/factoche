import { assign, setup } from "xstate";
import { z } from "zod";
import {
  formSchema,
  step1FormSchema,
  step2FormSchema,
} from "./project-form.schema";

const formInitialValues: z.infer<typeof formSchema> = {
  name: "",
  description: "",
  client_id: 0,
  retention_guarantee_rate: 0,
  items: [],
};

const projectFormMachine = setup({
  types: {
    context: {} as { formData: z.infer<typeof formSchema> },
    events: {} as
      | {
          type: "GO_FROM_STEP_1_TO_STEP_2";
          formData: z.infer<typeof step1FormSchema>;
        }
      | {
          type: "GO_FROM_STEP_2_TO_STEP_1";
          formData: z.infer<typeof step2FormSchema>;
        }
      | {
          type: "GO_FROM_STEP_2_TO_STEP_3";
          formData: z.infer<typeof step2FormSchema>;
        }
      | {
          type: "GO_FROM_STEP_3_TO_STEP_2";
        },
  },
  actions: {
    saveFormData: assign(({ context, event }) =>
      "formData" in event
        ? {
            formData: {
              ...context.formData,
              ...event.formData,
            },
          }
        : context
    ),
  },
}).createMachine({
  id: "projectMultiStepForm",
  initial: "step1",
  context: {
    formData: formInitialValues,
  },
  states: {
    step1: {
      on: {
        GO_FROM_STEP_1_TO_STEP_2: {
          target: "step2",
          actions: "saveFormData",
        },
      },
    },
    step2: {
      on: {
        GO_FROM_STEP_2_TO_STEP_1: {
          target: "step1",
          actions: "saveFormData",
        },
        GO_FROM_STEP_2_TO_STEP_3: {
          target: "completed",
          actions: "saveFormData",
        },
      },
    },
    completed: {
      type: "final",
      on: {
        GO_FROM_STEP_3_TO_STEP_2: {
          target: "step2",
        },
      },
    },
  },
});

export { projectFormMachine };
