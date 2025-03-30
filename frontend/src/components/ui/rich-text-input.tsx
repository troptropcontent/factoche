import { useEditor, EditorContent } from "@tiptap/react";
import StarterKit from "@tiptap/starter-kit";
import Heading from "@tiptap/extension-heading";
import Paragraph from "@tiptap/extension-paragraph";
import BulletList from "@tiptap/extension-bullet-list";
import OrderedList from "@tiptap/extension-ordered-list";
import ListItem from "@tiptap/extension-list-item";
import Placeholder from "@tiptap/extension-placeholder";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import {
  Bold,
  Italic,
  List,
  ListOrdered,
  Heading1,
  Heading2,
  Heading3,
  Undo,
  Redo,
} from "lucide-react";
import { useController, useFormContext } from "react-hook-form";

const RichTextInput = ({ input }: { input: string }) => {
  const { control, setValue } = useFormContext();
  const { field } = useController({ name: input, control });

  const editor = useEditor({
    editorProps: {
      attributes: {
        class: "prose prose-sm sm:prose mx-auto focus:outline-none",
      },
    },
    extensions: [
      StarterKit,
      Heading,
      Paragraph,
      BulletList.configure({
        HTMLAttributes: { class: "list-disc" },
      }),
      OrderedList,
      ListItem,
      Placeholder.configure({
        placeholder: "Write your terms and conditions here...",
      }),
    ],
    content: field.value,
    onUpdate: (document) => setValue(input, document.editor.getHTML()),
  });

  if (!editor) {
    return null;
  }

  return (
    <Card className="w-full mx-auto">
      <CardContent>
        <div className="mb-4 flex flex-wrap gap-2 border-b pb-4 mt-4">
          <Button
            variant="outline"
            size="icon"
            onClick={() => editor.chain().focus().toggleBold().run()}
            className={editor.isActive("bold") ? "bg-muted" : ""}
            title="Bold"
          >
            <Bold className="h-4 w-4" />
          </Button>
          <Button
            variant="outline"
            size="icon"
            onClick={() => editor.chain().focus().toggleItalic().run()}
            className={editor.isActive("italic") ? "bg-muted" : ""}
            title="Italic"
          >
            <Italic className="h-4 w-4" />
          </Button>
          <Button
            variant="outline"
            size="icon"
            onClick={() =>
              editor.chain().focus().toggleHeading({ level: 1 }).run()
            }
            className={
              editor.isActive("heading", { level: 1 }) ? "bg-muted" : ""
            }
            title="Heading 1"
          >
            <Heading1 className="h-4 w-4" />
          </Button>
          <Button
            variant="outline"
            size="icon"
            onClick={() =>
              editor.chain().focus().toggleHeading({ level: 2 }).run()
            }
            className={
              editor.isActive("heading", { level: 2 }) ? "bg-muted" : ""
            }
            title="Heading 2"
          >
            <Heading2 className="h-4 w-4" />
          </Button>
          <Button
            variant="outline"
            size="icon"
            onClick={() =>
              editor.chain().focus().toggleHeading({ level: 3 }).run()
            }
            className={
              editor.isActive("heading", { level: 3 }) ? "bg-muted" : ""
            }
            title="Heading 3"
          >
            <Heading3 className="h-4 w-4" />
          </Button>
          <Button
            variant="outline"
            size="icon"
            onClick={() => editor.chain().focus().toggleBulletList().run()}
            className={editor.isActive("bulletList") ? "bg-muted" : ""}
            title="Bullet List"
          >
            <List className="h-4 w-4" />
          </Button>
          <Button
            variant="outline"
            size="icon"
            onClick={() => editor.chain().focus().toggleOrderedList().run()}
            className={editor.isActive("orderedList") ? "bg-muted" : ""}
            title="Ordered List"
          >
            <ListOrdered className="h-4 w-4" />
          </Button>
          <Button
            variant="outline"
            size="icon"
            onClick={() => editor.chain().focus().undo().run()}
            disabled={!editor.can().undo()}
            title="Undo"
          >
            <Undo className="h-4 w-4" />
          </Button>
          <Button
            variant="outline"
            size="icon"
            onClick={() => editor.chain().focus().redo().run()}
            disabled={!editor.can().redo()}
            title="Redo"
          >
            <Redo className="h-4 w-4" />
          </Button>
        </div>

        <div className="min-h-[300px] border rounded-md p-4">
          <EditorContent
            editor={editor}
            className="prose max-w-none focus:outline-none"
          />
        </div>
      </CardContent>
    </Card>
  );
};

export { RichTextInput };
