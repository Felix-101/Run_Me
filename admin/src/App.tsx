import { Navigate, Route, Routes } from "react-router-dom";
import ProtectedRoute from "./components/ProtectedRoute";
import LoginView from "./views/LoginView";
import NotAuthorizedView from "./views/NotAuthorizedView";
import AdminLayout from "./layout/AdminLayout";
import DashboardPage from "./views/pages/DashboardPage";
import UsersPage, { UserDetailPage } from "./views/pages/UsersPage";
import LoansPage, { LoanDetailPage } from "./views/pages/LoansPage";
import TransactionsPage from "./views/pages/TransactionsPage";
import GrantsPage, { GrantDetailPage } from "./views/pages/GrantsPage";
import SettingsPage from "./views/pages/SettingsPage";

export default function App() {
  return (
    <Routes>
      <Route path="/login" element={<LoginView />} />
      <Route path="/not-authorized" element={<NotAuthorizedView />} />

      <Route element={<ProtectedRoute requireAdmin />}>
        <Route element={<AdminLayout />}>
          <Route index element={<DashboardPage />} />
          <Route path="users" element={<UsersPage />} />
          <Route path="users/:userId" element={<UserDetailPage />} />
          <Route path="loans" element={<LoansPage />} />
          <Route path="loans/:loanId" element={<LoanDetailPage />} />
          <Route path="transactions" element={<TransactionsPage />} />
          <Route path="grants" element={<GrantsPage />} />
          <Route path="grants/:grantId" element={<GrantDetailPage />} />
          <Route path="settings" element={<SettingsPage />} />
        </Route>
      </Route>

      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}
