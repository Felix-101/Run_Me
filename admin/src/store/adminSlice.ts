import { createAsyncThunk, createSlice } from "@reduxjs/toolkit";
import { apiFetch } from "../services/api";
import type { AdminSummary } from "../models/admin";

type AdminState = {
  summary: AdminSummary | null;
  status: "idle" | "loading" | "error";
  error: string | null;
};

const initialState: AdminState = {
  summary: null,
  status: "idle",
  error: null
};

export const fetchAdminSummaryThunk = createAsyncThunk<AdminSummary>(
  "admin/fetchSummary",
  async () => {
    return apiFetch<AdminSummary>("/admin/summary", { method: "GET", auth: true });
  }
);

const adminSlice = createSlice({
  name: "admin",
  initialState,
  reducers: {
    clearSummary(state) {
      state.summary = null;
      state.status = "idle";
      state.error = null;
    }
  },
  extraReducers(builder) {
    builder
      .addCase(fetchAdminSummaryThunk.pending, (state) => {
        state.status = "loading";
        state.error = null;
      })
      .addCase(fetchAdminSummaryThunk.fulfilled, (state, action) => {
        state.status = "idle";
        state.summary = action.payload;
      })
      .addCase(fetchAdminSummaryThunk.rejected, (state, action) => {
        state.status = "error";
        state.error = action.error.message ?? "Failed to load summary";
        state.summary = null;
      });
  }
});

export const { clearSummary } = adminSlice.actions;
export const adminReducer = adminSlice.reducer;

