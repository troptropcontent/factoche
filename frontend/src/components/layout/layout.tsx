import { SidebarProvider, SidebarTrigger } from "@/components/ui/sidebar";
import { AppSidebar } from "./components/app-sidebar";

const Layout = ({ children, companyId }: { children: React.ReactNode, companyId: string }) => {
  return (
    <SidebarProvider>
      <AppSidebar companyId={companyId}/>
      <main>
        <SidebarTrigger />
        {children}
      </main>
    </SidebarProvider>
  );
};

export { Layout };
