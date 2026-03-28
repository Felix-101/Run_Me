export type AdminSummary = {
  usersCount: number;
  generatedAt: string;
};

export type Paginated<T> = {
  items: T[];
  nextCursor: string | null;
};

export type AdminUserRow = {
  id: string;
  email: string;
  role: string;
  displayName: string | null;
  schoolName: string | null;
  studentIdVerified: boolean;
  createdAt: string;
};

export type AdminLoanRow = {
  id: string;
  borrowerId: string;
  lenderId: string | null;
  amount: number;
  purpose: string;
  durationDays: number;
  interestRate: number;
  status: string;
  audience: string;
  reason: string | null;
  proofFileUrl: string | null;
  repaidAmount: number;
  createdAt: string;
};

export type AdminGrantRow = {
  id: string;
  requesterId: string;
  title: string;
  story: string;
  goalNaira: number;
  raisedNaira: number;
  category: string;
  studentName: string;
  isUrgent: boolean;
  attachmentUrls: string[];
  createdAt: string;
};

export type AdminAuditRow = {
  id: string;
  actorId: string | null;
  action: string;
  resource: string;
  meta: Record<string, unknown>;
  createdAt: string;
};

/** UI-only until backend exposes a ledger */
export type TransactionRow = {
  id: string;
  userId: string;
  userLabel: string;
  type: "Deposit" | "Withdrawal" | "Loan" | "Grant" | "Repayment";
  amount: number;
  status: "Success" | "Failed" | "Pending";
  createdAt: string;
};
