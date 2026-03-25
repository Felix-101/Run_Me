import { useDispatch, useSelector } from "react-redux";
import type { AppDispatch, RootState } from "../store/store";
import { fetchAdminSummaryThunk } from "../store/adminSlice";

export function useAdminViewModel() {
  const dispatch = useDispatch<AppDispatch>();
  const admin = useSelector((s: RootState) => s.admin);

  return {
    ...admin,
    fetchSummary: () => dispatch(fetchAdminSummaryThunk()).unwrap()
  };
}

