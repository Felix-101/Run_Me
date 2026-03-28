import type { TransactionRow } from "../models/admin";

export const MOCK_TRANSACTIONS: TransactionRow[] = [
  {
    id: "tx_001",
    userId: "usr_a",
    userLabel: "Marcus Thorne",
    type: "Loan",
    amount: 50000,
    status: "Success",
    createdAt: new Date(Date.now() - 1000 * 60 * 12).toISOString()
  },
  {
    id: "tx_002",
    userId: "usr_b",
    userLabel: "Elena Vance",
    type: "Grant",
    amount: 15000,
    status: "Pending",
    createdAt: new Date(Date.now() - 1000 * 60 * 45).toISOString()
  },
  {
    id: "tx_003",
    userId: "usr_c",
    userLabel: "System · Vault",
    type: "Deposit",
    amount: 250000,
    status: "Success",
    createdAt: new Date(Date.now() - 1000 * 60 * 120).toISOString()
  },
  {
    id: "tx_004",
    userId: "usr_d",
    userLabel: "Kwame A.",
    type: "Withdrawal",
    amount: 8200,
    status: "Failed",
    createdAt: new Date(Date.now() - 1000 * 60 * 180).toISOString()
  },
  {
    id: "tx_005",
    userId: "usr_e",
    userLabel: "Chioma O.",
    type: "Repayment",
    amount: 12000,
    status: "Success",
    createdAt: new Date(Date.now() - 1000 * 60 * 240).toISOString()
  }
];
