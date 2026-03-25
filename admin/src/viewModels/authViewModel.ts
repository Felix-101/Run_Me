import { useDispatch, useSelector } from "react-redux";
import type { AppDispatch, RootState } from "../store/store";
import { fetchMeThunk, hydrateToken, loginThunk, logout } from "../store/authSlice";
import type { LoginRequest } from "../models/auth";

export function useAuthViewModel() {
  const dispatch = useDispatch<AppDispatch>();
  const auth = useSelector((s: RootState) => s.auth);

  return {
    ...auth,
    login: (input: LoginRequest) => dispatch(loginThunk(input)).unwrap(),
    fetchMe: () => dispatch(fetchMeThunk()).unwrap(),
    logout: () => dispatch(logout()),
    hydrateToken: () => dispatch(hydrateToken())
  };
}

