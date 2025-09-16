import { ProjectFormContent } from "./project-form-content";
import { z } from "zod";
import { formSchema } from "./project-form.schema";

type ProjectFormProps = {
  update?: boolean;
  companyId: string;
  initialValues: z.infer<typeof formSchema>;
  submitFunction: (data: z.infer<typeof formSchema>) => void;
};
const ProjectForm = ({
  update,
  companyId,
  initialValues,
  submitFunction,
}: ProjectFormProps) => {
  console.log({initialValues})
  return (
    <ProjectFormContent
      update={update}
      companyId={companyId}
      initialProjectFormValues={initialValues}
      submitFunction={submitFunction}
    />
  );
};

export { ProjectForm };
