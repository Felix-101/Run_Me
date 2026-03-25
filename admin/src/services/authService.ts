import { apiFetch } from "./api";
import type { LoginRequest, LoginResponse, Me } from "../models/auth";

export async function login(input: LoginRequest): Promise<LoginResponse> {
  return apiFetch("/auth/login", {
    method: "POST",
    body: JSON.stringify(input)
  });
}

export async function fetchMe(): Promise<Me> {
  return apiFetch<Me>("/me", { method: "GET", auth: true });
}

