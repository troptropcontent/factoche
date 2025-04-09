import { useTranslation } from "react-i18next";
import { CSV_FIELDS, PROJECT_FORM_INITIAL_VALUES } from "./constants";
import { v4 as uuidv4 } from "uuid";
import { z } from "zod";
import { formSchema, step2FormSchema } from "../project-form.schema";
import { ProjectType } from "./types";
import { Api } from "@/lib/openapi-fetch-query-client";
import { buildProjectFormInitialValue } from "./utils";

type CsvFieldKey = keyof typeof CSV_FIELDS;
type CsvFieldLabel = string;

const useCsvFieldsMapping = () => {
  const { t } = useTranslation();

  const getLabel = (key: string) =>
    t(
      `pages.companies.projects.form.composition_step.import_csv_modal.tabs.upload.expected_columns.${key}`
    );

  const mapping: Record<CsvFieldLabel, CsvFieldKey> = Object.keys(
    CSV_FIELDS
  ).reduce(
    (prev, field) => {
      const label = getLabel(field as CsvFieldKey);
      prev[label] = field as CsvFieldKey;
      return prev;
    },
    {} as Record<CsvFieldLabel, CsvFieldKey>
  );

  const reverseMapping: Record<CsvFieldKey, CsvFieldLabel> = Object.keys(
    CSV_FIELDS
  ).reduce(
    (prev, field) => {
      const label = getLabel(field as CsvFieldKey);
      prev[field as CsvFieldKey] = label;
      return prev;
    },
    {} as Record<CsvFieldKey, CsvFieldLabel>
  );

  return { mapping, reverseMapping };
};

type ParsedItem = z.infer<typeof step2FormSchema>["items"][number];
type ParsedGroup = z.infer<typeof step2FormSchema>["groups"][number];
type CSVField = keyof typeof CSV_FIELDS;
type FieldType<T extends CSVField> = (typeof CSV_FIELDS)[T]["type"];

type ParsedValue<T extends CSVField> =
  | { data: FieldType<T> extends "string" ? string : number; error: undefined }
  | { data: undefined; error: string };

const useCsvFields = (appendToDebugInfo: (debugInfo: string) => void) => {
  const { t } = useTranslation();

  const getHeader = (fieldKey: keyof typeof CSV_FIELDS) =>
    t(
      `pages.companies.projects.form.composition_step.import_csv_modal.tabs.upload.expected_columns.${fieldKey}`
    );
  const getParsedValue = <T extends keyof typeof CSV_FIELDS>(
    field: T,
    row: Record<string, string>
  ): ParsedValue<T> => {
    const header = getHeader(field);
    const value = row[header];
    if (value === undefined || value === "") {
      return { data: undefined, error: "missing_data" };
    }

    const type = CSV_FIELDS[field].type;

    if (type === "string") {
      return { data: value, error: undefined } as ParsedValue<T>;
    }

    const parsedValue = Number(value);
    if (Number.isNaN(parsedValue)) {
      return { data: undefined, error: "invalid_number_data" };
    }

    if (type === "number") {
      return { data: parsedValue, error: undefined } as ParsedValue<T>;
    }

    if (parsedValue < 0 || parsedValue > 100) {
      return { data: undefined, error: "invalid_percentage_data" };
    }
    return { data: parsedValue, error: undefined } as ParsedValue<T>;
  };
  const parseCsvResult = ({
    data: rows,
    meta,
  }: Papa.ParseResult<Record<string, string>>):
    | { error: string; parsedData: undefined }
    | {
        error: undefined;
        parsedData: {
          items: ParsedItem[];
          groups: ParsedGroup[];
        };
      } => {
    const headers = meta.fields;
    if (!headers) {
      return {
        error: t(
          "pages.companies.projects.form.composition_step.import_csv_modal.errors.no_headers_detected"
        ),
        parsedData: undefined,
      };
    }

    const missingFields = Object.keys(CSV_FIELDS)
      .map((field) => getHeader(field as keyof typeof CSV_FIELDS))
      .filter((fieldHeader) => !headers.includes(fieldHeader));

    if (missingFields.length > 0) {
      return {
        error: t(
          "pages.companies.projects.form.composition_step.import_csv_modal.errors.missing_fields",
          { missingFields: missingFields.join(", ") }
        ),
        parsedData: undefined,
      };
    }

    appendToDebugInfo(
      t(
        "pages.companies.projects.form.composition_step.import_csv_modal.debug_info.detected_fields",
        {
          headers: headers.join(", "),
        }
      )
    );

    const parsedItems: ParsedItem[] = [];
    const parsedGroupsMap: Map<string, ParsedGroup> = new Map();
    let parsedGroupCount = 0;

    for (const [rowIndex, row] of rows.entries()) {
      const lineNumber = rowIndex + 1;
      const { data: parsedName, error: parsedNameError } = getParsedValue(
        "name",
        row
      );
      if (parsedNameError != undefined) {
        return {
          error: t(
            `pages.companies.projects.form.composition_step.import_csv_modal.errors.${parsedNameError}`,
            { line: lineNumber, column: getHeader("name") }
          ),
          parsedData: undefined,
        };
      }

      const { data: parsedQuantity, error: parsedQuantityError } =
        getParsedValue("quantity", row);
      if (parsedQuantityError != undefined) {
        return {
          error: t(
            `pages.companies.projects.form.composition_step.import_csv_modal.errors.${parsedQuantityError}`,
            { line: lineNumber, column: getHeader("quantity") }
          ),
          parsedData: undefined,
        };
      }

      const { data: parsedUnit, error: parsedUnitError } = getParsedValue(
        "unit",
        row
      );
      if (parsedUnitError != undefined) {
        return {
          error: t(
            `pages.companies.projects.form.composition_step.import_csv_modal.errors.${parsedUnitError}`,
            { line: lineNumber, column: getHeader("unit") }
          ),
          parsedData: undefined,
        };
      }

      const { data: parsedUnitPrice, error: parsedUnitPriceError } =
        getParsedValue("unit_price_amount", row);
      if (parsedUnitPriceError != undefined) {
        return {
          error: t(
            `pages.companies.projects.form.composition_step.import_csv_modal.errors.${parsedUnitPriceError}`,
            { line: lineNumber, column: getHeader("unit_price_amount") }
          ),
          parsedData: undefined,
        };
      }

      const { data: parsedVatRate, error: parsedVatRateError } = getParsedValue(
        "tax_rate",
        row
      );
      if (parsedVatRateError != undefined) {
        return {
          error: t(
            `pages.companies.projects.form.composition_step.import_csv_modal.errors.${parsedVatRateError}`,
            { line: lineNumber, column: getHeader("tax_rate") }
          ),
          parsedData: undefined,
        };
      }

      const { data: parsedGroup, error: parsedGroupError } = getParsedValue(
        "group",
        row
      );
      if (parsedGroupError != undefined) {
        return {
          error: t(
            `pages.companies.projects.form.composition_step.import_csv_modal.errors.${parsedGroupError}`,
            { line: lineNumber, column: getHeader("group") }
          ),
          parsedData: undefined,
        };
      }

      if (!parsedGroupsMap.has(parsedGroup)) {
        parsedGroupsMap.set(parsedGroup, {
          uuid: uuidv4(),
          name: parsedGroup,
          position: Array.from(parsedGroupsMap.values()).length + 1,
        });
        ++parsedGroupCount;
      }

      const groupUuid = parsedGroupsMap.get(parsedGroup)!.uuid;

      const position =
        parsedItems.filter((item) => item.group_uuid === groupUuid).length + 1;

      parsedItems.push({
        uuid: uuidv4(),
        position: position,
        group_uuid: groupUuid,
        name: parsedName,
        quantity: parsedQuantity,
        unit: parsedUnit,
        unit_price_amount: parsedUnitPrice,
        tax_rate: parsedVatRate,
      });
    }

    if (parsedItems.length == 0) {
      return {
        error: t(
          `pages.companies.projects.form.composition_step.import_csv_modal.errors.no_items_detected`
        ),
        parsedData: undefined,
      };
    }

    appendToDebugInfo(
      t(
        "pages.companies.projects.form.composition_step.import_csv_modal.debug_info.detected_groups",
        {
          count: parsedGroupCount,
        }
      )
    );

    appendToDebugInfo(
      t(
        "pages.companies.projects.form.composition_step.import_csv_modal.debug_info.detected_items",
        {
          count: parsedItems.length,
        }
      )
    );

    return {
      error: undefined,
      parsedData: {
        items: parsedItems,
        groups: Array.from(parsedGroupsMap.values()),
      },
    };
  };

  return { parseCsvResult };
};

const useProjectFormInitialValues = (options?: {
  projectId: string;
  projectType: ProjectType;
}): undefined | z.infer<typeof formSchema> => {
  const { data: quote } = Api.useQuery(
    "get",
    "/api/v1/organization/quotes/{id}",
    { params: { path: { id: Number(options?.projectId) } } },
    {
      enabled: options?.projectType === "quote",
      select: ({ result }) => result,
    }
  );
  const { data: draftOrder } = Api.useQuery(
    "get",
    "/api/v1/organization/draft_orders/{id}",
    { params: { path: { id: Number(options?.projectId) } } },
    {
      enabled: options?.projectType === "draftOrder",
      select: ({ result }) => result,
    }
  );
  const { data: order } = Api.useQuery(
    "get",
    "/api/v1/organization/orders/{id}",
    { params: { path: { id: Number(options?.projectId) } } },
    {
      enabled: options?.projectType === "order",
      select: ({ result }) => result,
    }
  );

  if (options == undefined) {
    return PROJECT_FORM_INITIAL_VALUES;
  }

  const project = quote || draftOrder || order;

  if (project == undefined) {
    return undefined;
  }

  return buildProjectFormInitialValue(project);
};

export { useCsvFieldsMapping, useCsvFields, useProjectFormInitialValues };
