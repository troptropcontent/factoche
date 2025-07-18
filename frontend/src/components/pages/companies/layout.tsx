import { Separator } from "@/components/ui/separator";
import { SidebarTrigger } from "@/components/ui/sidebar";
import { Skeleton } from "@/components/ui/skeleton";
import { ReactNode } from "@tanstack/react-router";

const Header = ({ children }: { children: ReactNode }) => {
  return (
    <header className="flex h-16 shrink-0 items-center gap-2 border-b">
      <div className="flex items-center gap-2 px-3 flex-grow">
        <SidebarTrigger />
        <Separator orientation="vertical" className="mr-2 h-4" />
        {children}
      </div>
    </header>
  );
};

const Content = ({ children }: { children: ReactNode }) => {
  return <div className="flex flex-1 flex-col gap-4 p-4">{children}</div>;
};

const Root = ({ children }: { children: ReactNode }) => children;

const LoadingLayout = () => {
  return (
    <Layout.Root>
      <Layout.Header>
        <Skeleton className="h-8 w-full" />
      </Layout.Header>
      <Layout.Content>
        <Skeleton className="h-full w-full" />
      </Layout.Content>
    </Layout.Root>
  );
};

const Layout = {
  Root,
  Header,
  Content,
};

export { Layout, LoadingLayout };
