import { createAsyncThunk, createSlice } from "@reduxjs/toolkit";
import { login as loginApi, fetchMe as fetchMeApi } from "../services/authService";
import type { LoginRequest, LoginResponse, Me } from "../models/auth";

type AuthState = {
  accessToken: string | null;
  me: Me | null;
  status: "idle" | "loading" | "error";
  error: string | null;
};

const initialToken = localStorage.getItem("accessToken");

const initialState: AuthState = {
  accessToken: initialToken,
  me: null,
  status: "idle",
  error: null
};

export const loginThunk = createAsyncThunk<LoginResponse, LoginRequest>(
  "auth/login",
  async (input) => {
    const res = await loginApi(input);
    return res;
  }
);

export const fetchMeThunk = createAsyncThunk<Me>(
  "auth/fetchMe",
  async () => {
    return fetchMeApi();
  }
);

const authSlice = createSlice({
  name: "auth",
  initialState,
  reducers: {
    logout(state) {
      state.accessToken = null;
      state.me = null;
      state.status = "idle";
      state.error = null;
      localStorage.removeItem("accessToken");
    },
    hydrateToken(state) {
      state.accessToken = localStorage.getItem("accessToken");
    }
  },
  extraReducers(builder) {
    builder
      .addCase(loginThunk.pending, (state) => {
        state.status = "loading";
        state.error = null;
      })
      .addCase(loginThunk.fulfilled, (state, action) => {
        state.status = "idle";
        state.accessToken = action.payload.accessToken;
        localStorage.setItem("accessToken", action.payload.accessToken);
      })
      .addCase(loginThunk.rejected, (state, action) => {
        state.status = "error";
        state.error = action.error.message ?? "Login failed";
      })
      .addCase(fetchMeThunk.pending, (state) => {
        state.status = "loading";
        state.error = null;
      })
      .addCase(fetchMeThunk.fulfilled, (state, action) => {
        state.status = "idle";
        state.me = action.payload;
      })
      .addCase(fetchMeThunk.rejected, (state, action) => {
        state.status = "error";
        state.error = action.error.message ?? "Failed to load profile";
        state.me = null;
      });
  }
});

export const { logout, hydrateToken } = authSlice.actions;
export const authReducer = authSlice.reducer;

