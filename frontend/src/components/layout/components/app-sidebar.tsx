import { Button } from "@/components/ui/button";
import {
  Sidebar,
  SidebarContent,
  SidebarFooter,
  SidebarGroup,
  SidebarGroupContent,
  SidebarGroupLabel,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
} from "@/components/ui/sidebar";
import { useAuth } from "@/hooks/use_auth";
import { Link, useRouter } from "@tanstack/react-router";
import { Cuboid, Handshake, ReceiptText, Settings } from "lucide-react";

export function AppSidebar({ companyId }: { companyId: string }) {
  const { logout } = useAuth();
  const router = useRouter();

  const items = [
    {
      title: "Projets",
      url: `/organization/companies/${companyId}/projects`,
      icon: Cuboid,
    },
    {
      title: "Factures",
      url: `/organization/companies/${companyId}/invoices`,
      icon: ReceiptText,
    },
    {
      title: "Clients",
      url: `/organization/companies/${companyId}/clients`,
      icon: Handshake,
    },
    {
      title: "Settings",
      url: `/organization/companies/${companyId}/settings`,
      icon: Settings,
    },
  ];

  return (
    <Sidebar>
      <SidebarContent>
        <SidebarGroup>
          <SidebarGroupLabel>Application</SidebarGroupLabel>
          <SidebarGroupContent>
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
          </SidebarGroupContent>
        </SidebarGroup>
      </SidebarContent>
      <SidebarFooter>
        <Button
          onClick={() => {
            logout();
            router.invalidate();
          }}
        >
          Logout
        </Button>
      </SidebarFooter>
    </Sidebar>
  );
}
