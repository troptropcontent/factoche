import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { ReactNode } from "@tanstack/react-router";
import { cloneElement } from "react";

/**
 * Root component for the KPI card that wraps all other components
 * @param {Object} props - Component props
 * @param {ReactNode} props.children - Child elements to be rendered inside the card
 * @returns {JSX.Element} A Card component containing the children
 */
const Root = ({ children }: { children: ReactNode }) => <Card>{children}</Card>;

/**
 * Header component for the KPI card that provides consistent styling
 * @param {Object} props - Component props
 * @param {ReactNode} props.children - Child elements to be rendered in the header
 * @returns {JSX.Element} A styled CardHeader component
 */
const Header = ({ children }: { children: ReactNode }) => (
  <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
    {children}
  </CardHeader>
);

/**
 * Title component for the KPI card that displays the metric name
 * @param {Object} props - Component props
 * @param {ReactNode} props.children - Text content for the title
 * @returns {JSX.Element} A styled CardTitle component
 */
const Title = ({ children }: { children: ReactNode }) => (
  <CardTitle className="text-sm font-medium">{children}</CardTitle>
);

/**
 * Icon component for displaying icons in the KPI card
 * @param {Object} props - Component props
 * @param {ReactNode} props.children - The icon component to be displayed
 * @returns {JSX.Element} A styled icon with merged classes
 */
const Icon = ({ children }: { children: ReactNode }) => {
  return cloneElement(children as React.ReactElement, {
    className: `h-4 w-4 text-muted-foreground ${(children as React.ReactElement).props.className || ""}`,
  });
};

/**
 * Content component for the KPI card that wraps the main content area
 * @param {Object} props - Component props
 * @param {ReactNode} props.children - Child elements to be rendered in the content area
 * @returns {JSX.Element} A CardContent component
 */
const Content = ({ children }: { children: ReactNode }) => (
  <CardContent>{children}</CardContent>
);

/**
 * MainInfo component for displaying the primary KPI value
 * @param {Object} props - Component props
 * @param {ReactNode} props.children - The main KPI value to be displayed
 * @returns {JSX.Element} A styled div containing the main KPI value
 */
const MainInfo = ({ children }: { children: ReactNode }) => (
  <div className="text-2xl font-bold">{children}</div>
);

/**
 * SecondaryInfo component for displaying additional context or comparison data
 * @param {Object} props - Component props
 * @param {ReactNode} props.children - The secondary information to be displayed
 * @returns {JSX.Element} A styled paragraph containing the secondary information
 */
const SecondaryInfo = ({ children }: { children: ReactNode }) => {
  if (typeof children == "object") {
    return <>{children}</>
  } else {
    return <p className="text-xs text-muted-foreground">{children}</p>
  }
};

/**
 * KpiCard component that provides a composable interface for creating KPI cards
 * @example
 * ```tsx
 * <KpiCard.Root>
 *   <KpiCard.Header>
 *     <KpiCard.Title>Total Revenue</KpiCard.Title>
 *   </KpiCard.Header>
 *   <KpiCard.Content>
 *     <KpiCard.MainInfo>$50,000</KpiCard.MainInfo>
 *     <KpiCard.SecondaryInfo>+20% from last month</KpiCard.SecondaryInfo>
 *   </KpiCard.Content>
 * </KpiCard.Root>
 * ```
 */
const KpiCard = {
  Root,
  Header,
  Title,
  Content,
  MainInfo,
  SecondaryInfo,
  Icon,
};

export { KpiCard };
