import { Navigate, Route, Routes } from "react-router-dom";
import ProtectedRoute from "./components/ProtectedRoute";
import LoginView from "./views/LoginView";
import DashboardView from "./views/DashboardView";
import NotAuthorizedView from "./views/NotAuthorizedView";

export default function App() {
  return (
    <Routes>
      <Route path="/login" element={<LoginView />} />
      <Route path="/not-authorized" element={<NotAuthorizedView />} />

      <Route
        path="/"
        element={
          <ProtectedRoute requireAdmin>
            <DashboardView />
          </ProtectedRoute>
        }
      />

      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}

