import { AuthContext } from "@/auth";
import { Button } from "@/components/ui/button";
import {
  Sidebar,
  SidebarContent,
  SidebarFooter,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
} from "@/components/ui/sidebar";
import { Link, useRouter } from "@tanstack/react-router";
import {
  Cuboid,
  Handshake,
  LayoutDashboard,
  ReceiptText,
  Settings,
  FileText,
} from "lucide-react";
import { useContext } from "react";

export function AppSidebar() {
  const authContext = useContext(AuthContext);
  if (authContext === null) {
    throw new Error("AuthContext must be used within an AuthProvider");
  }
  const router = useRouter();

  const items = [
    {
      title: "Dashboard",
      url: ``,
      icon: LayoutDashboard,
    },
    {
      title: "Commandes",
      url: `orders`,
      icon: Cuboid,
    },
    {
      title: "Devis",
      url: `quotes`,
      icon: FileText,
    },
    {
      title: "Factures",
      url: `invoices`,
      icon: ReceiptText,
    },
    {
      title: "Clients",
      url: `clients`,
      icon: Handshake,
    },
    {
      title: "Paramétres",
      url: `settings`,
      icon: Settings,
    },
  ];

  return (
    <Sidebar>
      <SidebarContent>
        <SidebarMenu>
          {items.map((item) => (
            <SidebarMenuItem key={item.title}>
              <SidebarMenuButton asChild>
                <Link to={item.url}>
                  <item.icon />
                  <span>{item.title}</span>
                </Link>
              </SidebarMenuButton>
            </SidebarMenuItem>
          ))}
        </SidebarMenu>
      </SidebarContent>
      <SidebarFooter>
        <Button
          onClick={() => {
            authContext.logout();
            router.invalidate();
          }}
          variant="outline"
        >
          Logout
        </Button>
      </SidebarFooter>
    </Sidebar>
  );
}
