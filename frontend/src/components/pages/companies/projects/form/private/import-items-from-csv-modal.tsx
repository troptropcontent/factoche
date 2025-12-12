import type React from "react";
import { useState, useRef } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import Papa from "papaparse";
import {
  Table,
  TableBody,
  TableCell,
  TableFooter,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import {
  Upload,
  AlertCircle,
  FileText,
  Download,
  ArrowRight,
  Check,
  FileUp,
} from "lucide-react";
import { useTranslation } from "react-i18next";
import { buildCsvTemplateData } from "./utils";
import { useCsvFields, useCsvFieldsMapping } from "./hooks";
import { z } from "zod";
import { step2FormSchema } from "../project-form.schema";

export function ImportItemsFromCsvModal({
  setInitialFormValues,
}: {
  setInitialFormValues: (
    initialFormValues: z.infer<typeof step2FormSchema>
  ) => void;
}) {
  const { t } = useTranslation();
  const fileInputRef = useRef<HTMLInputElement>(null);
  const [open, setOpen] = useState(false);
  const [file, setFile] = useState<File | null>(null);
  const [csvData, setCsvData] = useState<z.infer<typeof step2FormSchema>>({
    items: [],
    groups: [],
    discounts: [],
  });
  const [activeTab, setActiveTab] = useState<"upload" | "preview">("upload");
  const [error, setError] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState<boolean>(false);
  const [debugInfo, setDebugInfo] = useState<string | null>(null);
  const appendToDebugInfo = (debugInfo: string) =>
    setDebugInfo((prev) => `${prev ? `${prev}\n` : ""}${debugInfo}`);
  const { mapping: csvFieldMapping, reverseMapping: csvFieldReverseMapping } =
    useCsvFieldsMapping();
  const { parseCsvResult } = useCsvFields(appendToDebugInfo);

  const sampleCsvData = buildCsvTemplateData(t, csvFieldReverseMapping);

  const resetState = () => {
    setFile(null);
    setCsvData({ items: [], groups: [], discounts: [] });
    setActiveTab("upload");
    setError(null);
    setDebugInfo(null);
    setIsLoading(false);
  };

  const handleOpenChange = (newOpen: boolean) => {
    if (!newOpen) {
      resetState();
    }
    setOpen(newOpen);
  };

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const selectedFile = e.target.files?.[0];
    if (selectedFile) {
      setFile(selectedFile);
      setIsLoading(false);
      setError(null);
      setDebugInfo(null);
    }
  };

  const handleDragOver = (e: React.DragEvent<HTMLDivElement>) => {
    e.preventDefault();
    e.stopPropagation();
  };

  const handleDrop = (e: React.DragEvent<HTMLDivElement>) => {
    e.preventDefault();
    e.stopPropagation();

    if (e.dataTransfer.files && e.dataTransfer.files.length > 0) {
      const droppedFile = e.dataTransfer.files[0]!;
      if (
        droppedFile.type === "text/csv" ||
        droppedFile.name.endsWith(".csv")
      ) {
        setFile(droppedFile);
        setIsLoading(false);
        setError(null);
        setDebugInfo(null);
      } else {
        setError(
          t(
            "pages.companies.projects.form.composition_step.import_csv_modal.errors.csv_file_required"
          )
        );
      }
    }
  };

  const downloadSampleCsv = () => {
    const blob = new Blob([sampleCsvData], { type: "text/csv" });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.setAttribute("hidden", "");
    a.setAttribute("href", url);
    a.setAttribute("download", "quote_import_template.csv");
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
  };

  const parseCSV = () => {
    if (!file) {
      setError(
        t(
          "pages.companies.projects.form.composition_step.import_csv_modal.errors.file_required"
        )
      );
      return;
    }

    setIsLoading(true);
    setError(null);
    setDebugInfo(null);

    const onParsingSuccess = (
      result: Papa.ParseResult<Record<string, string>>
    ) => {
      const { parsedData, error } = parseCsvResult(result);
      if (error != undefined) {
        setIsLoading(false);
        setError(error);
        return;
      }
      setIsLoading(false);
      setCsvData({ ...parsedData, discounts: [] });
      setActiveTab("preview");
    };

    const onParsingError = () =>
      setError(
        t(
          "pages.companies.projects.form.composition_step.import_csv_modal.errors.parsing_error"
        )
      );

    Papa.parse(file, {
      header: true,
      skipEmptyLines: true,
      dynamicTyping: false,
      complete: onParsingSuccess,
      error: onParsingError,
    });
  };

  const handleImport = () => {
    setIsLoading(true);
    setInitialFormValues(csvData);
    setOpen(false);
  };

  return (
    <Dialog open={open} onOpenChange={handleOpenChange}>
      <DialogTrigger asChild>
        <Button variant="outline">
          <FileUp className="mr-2 h-4 w-4" />
          {t("pages.companies.projects.form.composition_step.import_csv")}
        </Button>
      </DialogTrigger>
      <DialogContent className="sm:max-w-[800px] max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>
            {t(
              "pages.companies.projects.form.composition_step.import_csv_modal.title"
            )}
          </DialogTitle>
          <DialogDescription>
            {t(
              "pages.companies.projects.form.composition_step.import_csv_modal.description"
            )}
          </DialogDescription>
        </DialogHeader>
        <div className="py-4">
          {error && (
            <Alert variant="destructive" className="mb-6">
              <AlertCircle className="h-4 w-4" />
              <AlertTitle>
                {t(
                  "pages.companies.projects.form.composition_step.import_csv_modal.errors.title"
                )}
              </AlertTitle>
              <AlertDescription>{error}</AlertDescription>
            </Alert>
          )}
          {debugInfo && (
            <Alert className="mb-6 bg-muted">
              <AlertTitle>
                {t(
                  "pages.companies.projects.form.composition_step.import_csv_modal.debug_info.title"
                )}
              </AlertTitle>
              <AlertDescription className="whitespace-pre-wrap font-mono text-xs">
                {debugInfo}
              </AlertDescription>
            </Alert>
          )}
          <Tabs
            value={activeTab}
            onValueChange={(value) => setActiveTab(value as typeof activeTab)}
          >
            <TabsList className="grid w-full grid-cols-2">
              <TabsTrigger value="upload">
                {t(
                  "pages.companies.projects.form.composition_step.import_csv_modal.tabs.upload.label"
                )}
              </TabsTrigger>
              <TabsTrigger value="preview" disabled={activeTab !== "preview"}>
                {t(
                  "pages.companies.projects.form.composition_step.import_csv_modal.tabs.preview.label"
                )}
              </TabsTrigger>
            </TabsList>

            <TabsContent value="upload" className="pt-4">
              <div className="space-y-6">
                <div
                  className="border-2 border-dashed border-muted-foreground/25 rounded-lg p-10 text-center"
                  onDragOver={handleDragOver}
                  onDrop={handleDrop}
                >
                  <Upload className="h-10 w-10 mx-auto mb-4 text-muted-foreground" />
                  <h3 className="text-lg font-medium mb-2">
                    {t(
                      "pages.companies.projects.form.composition_step.import_csv_modal.tabs.upload.drop_zone_title"
                    )}
                  </h3>
                  <p className="text-sm text-muted-foreground mb-4">
                    {t(
                      "pages.companies.projects.form.composition_step.import_csv_modal.tabs.upload.drop_zone_label"
                    )}
                  </p>
                  <Input
                    ref={fileInputRef}
                    id="csv-file"
                    type="file"
                    accept=".csv"
                    onChange={handleFileChange}
                    className="hidden"
                  />
                  <div className="flex flex-col sm:flex-row justify-center gap-4">
                    <Button
                      variant="outline"
                      type="button"
                      onClick={() => fileInputRef.current?.click()}
                    >
                      <FileText className="mr-2 h-4 w-4" />
                      {t(
                        "pages.companies.projects.form.composition_step.import_csv_modal.tabs.upload.drop_zone_upload_button_label"
                      )}
                    </Button>
                    <Button
                      variant="outline"
                      type="button"
                      onClick={downloadSampleCsv}
                    >
                      <Download className="mr-2 h-4 w-4" />
                      {t(
                        "pages.companies.projects.form.composition_step.import_csv_modal.tabs.upload.drop_zone_download_template_button_label"
                      )}
                    </Button>
                  </div>
                  {file && (
                    <div className="mt-4 p-3 bg-muted rounded-md inline-block">
                      <p className="text-sm flex items-center">
                        <Check className="h-4 w-4 mr-2 text-green-500" />
                        <span className="font-medium">{file.name}</span>
                        <span className="text-muted-foreground ml-2">
                          ({(file.size / 1024).toFixed(2)} KB)
                        </span>
                      </p>
                    </div>
                  )}
                </div>

                <div className="space-y-4">
                  <h3 className="text-lg font-medium">
                    {t(
                      "pages.companies.projects.form.composition_step.import_csv_modal.tabs.upload.expected_columns.label"
                    )}
                  </h3>
                  <p className="text-sm text-muted-foreground">
                    {t(
                      "pages.companies.projects.form.composition_step.import_csv_modal.tabs.upload.expected_columns.description"
                    )}
                  </p>
                  <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-2">
                    {Object.keys(csvFieldMapping).map((field) => (
                      <div
                        key={field}
                        className="flex items-center p-2 border rounded-md"
                      >
                        <span>{field}</span>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            </TabsContent>

            <TabsContent value="preview" className="pt-4">
              <div className="space-y-6">
                <h3 className="text-lg font-medium mb-4">
                  {t(
                    "pages.companies.projects.form.composition_step.import_csv_modal.tabs.preview.label"
                  )}
                </h3>
                <p className="text-sm text-muted-foreground mb-6">
                  {t(
                    "pages.companies.projects.form.composition_step.import_csv_modal.tabs.preview.title"
                  )}
                </p>
                <div className="border rounded-md overflow-auto">
                  <Table>
                    <TableHeader>
                      <TableRow>
                        {Object.keys(csvFieldMapping).map((field) => (
                          <TableHead key={field} className="whitespace-nowrap">
                            {field}
                          </TableHead>
                        ))}
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {csvData.items.map((item, rowIndex) => (
                        <TableRow key={rowIndex}>
                          {Object.keys(csvFieldReverseMapping).map((field) => (
                            <TableCell key={field}>
                              {field === "group"
                                ? csvData.groups.find(
                                    (group) => group.uuid === item.group_uuid
                                  )!.name
                                : item[field as keyof typeof item]}
                            </TableCell>
                          ))}
                        </TableRow>
                      ))}
                    </TableBody>
                    <TableFooter>
                      <TableRow>
                        <TableCell
                          colSpan={Object.keys(csvFieldMapping).length - 1}
                          className="text-right"
                        >
                          {t(
                            "pages.companies.projects.form.composition_step.import_csv_modal.tabs.preview.total_excl_vat_label"
                          )}
                        </TableCell>
                        <TableCell>
                          {t("common.number_in_currency", {
                            amount: csvData.items.reduce(
                              (prev, item) =>
                                prev +
                                Number(item.quantity) *
                                  Number(item.unit_price_amount),
                              0
                            ),
                          })}
                        </TableCell>
                      </TableRow>
                    </TableFooter>
                  </Table>
                </div>
              </div>
            </TabsContent>
          </Tabs>
        </div>

        <DialogFooter className="flex justify-between items-center">
          <div className="w-full flex flex-row-reverse justify-between">
            {(() => {
              switch (activeTab) {
                case "upload":
                  return (
                    <Button onClick={parseCSV} disabled={!file || isLoading}>
                      {isLoading
                        ? t(
                            "pages.companies.projects.form.composition_step.import_csv_modal.tabs.actions.processing_button_label"
                          )
                        : t(
                            "pages.companies.projects.form.composition_step.import_csv_modal.tabs.actions.continue_button_label"
                          )}
                      {!isLoading && <ArrowRight className="ml-2 h-4 w-4" />}
                    </Button>
                  );
                case "preview":
                  return (
                    <>
                      <div className="flex items-center gap-2">
                        <span className="text-sm text-muted-foreground">
                          {t(
                            "pages.companies.projects.form.composition_step.import_csv_modal.tabs.preview.number_of_element_imported_one",
                            { count: csvData.items.length }
                          )}
                        </span>
                        <Button
                          onClick={handleImport}
                          disabled={isLoading || csvData.items.length === 0}
                        >
                          {isLoading
                            ? t(
                                "pages.companies.projects.form.composition_step.import_csv_modal.tabs.actions.importing_button_label"
                              )
                            : t(
                                "pages.companies.projects.form.composition_step.import_csv_modal.tabs.actions.import_button_label"
                              )}
                        </Button>
                      </div>
                      <Button
                        variant="outline"
                        onClick={() => setActiveTab("upload")}
                      >
                        {t(
                          "pages.companies.projects.form.composition_step.import_csv_modal.tabs.actions.back_button_label"
                        )}
                      </Button>
                    </>
                  );
                default:
                  return null;
              }
            })()}
          </div>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
