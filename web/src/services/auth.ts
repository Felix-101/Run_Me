import { apiFetch } from "./api";

export type LoginRequest = {
  email: string;
  password: string;
};

export async function login(input: LoginRequest): Promise<{ accessToken: string }> {
  return apiFetch("/auth/login", {
    method: "POST",
    body: JSON.stringify(input)
  });
}

