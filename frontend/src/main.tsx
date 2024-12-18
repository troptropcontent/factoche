import ReactDOM from "react-dom/client";
import { App } from "./app";
import '@/config/i18n';
// Render the app
const rootElement = document.getElementById("root")!;
if (!rootElement.innerHTML) {
  const root = ReactDOM.createRoot(rootElement);
  root.render(<App />);
}
