declare module "@mapbox/search-js-react" {
  import { ForwardRefExoticComponent, RefAttributes } from "react";

  interface AddressAutofillProps {
    accessToken: string;
    children: React.ReactNode;
  }

  export const AddressAutofill: ForwardRefExoticComponent<
    AddressAutofillProps & RefAttributes<unknown>
  >;
}
