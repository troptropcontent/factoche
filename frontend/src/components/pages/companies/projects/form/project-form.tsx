import { ProjectFormContent } from "./project-form-content";
import { z } from "zod";
import { formSchema } from "./project-form.schema";

type ProjectFormProps = {
  companyId: string;
  initialValues: z.infer<typeof formSchema>;
  submitFunction: (data: z.infer<typeof formSchema>) => void;
};
const ProjectForm = ({
  companyId,
  initialValues,
  submitFunction,
}: ProjectFormProps) => {
  return (
    <ProjectFormContent
      companyId={companyId}
      initialProjectFormValues={initialValues}
      submitFunction={submitFunction}
    />
  );
};

export { ProjectForm };
