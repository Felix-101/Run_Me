export class ApiError extends Error {
  public readonly status: number;
  public readonly expose: boolean;

  constructor(message: string, status = 500, options?: { expose?: boolean }) {
    super(message);
    this.name = "ApiError";
    this.status = status;
    this.expose = options?.expose ?? status < 500;
  }
}

