import type { Express } from "express";
import swaggerUi from "swagger-ui-express";
import openapiSpec from "./openapi/openapi.json";

export function mountSwagger(app: Express) {
  app.use(
    "/docs",
    swaggerUi.serve,
    swaggerUi.setup(openapiSpec, {
      customSiteTitle: "RunMe API",
      customCss: ".swagger-ui .topbar { display: none }"
    })
  );

  app.get("/openapi.json", (_req, res) => res.json(openapiSpec));
}
