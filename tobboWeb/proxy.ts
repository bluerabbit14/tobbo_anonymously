import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";

const DEFAULT_ALLOW_HEADERS =
  "Accept, Authorization, Content-Type, Origin, X-Requested-With";

function withOpenCors(request: NextRequest, response: NextResponse) {
  const origin = request.headers.get("origin")?.trim() || "*";
  response.headers.set("Access-Control-Allow-Origin", origin);
  response.headers.set(
    "Access-Control-Allow-Methods",
    "GET, POST, PUT, PATCH, DELETE, OPTIONS, HEAD",
  );
  response.headers.set(
    "Access-Control-Allow-Headers",
    request.headers.get("access-control-request-headers") ?? DEFAULT_ALLOW_HEADERS,
  );
  response.headers.set("Access-Control-Expose-Headers", "*");
  response.headers.set("Access-Control-Max-Age", "86400");
  response.headers.set("Vary", "Origin");
  if (origin !== "*") {
    response.headers.set("Access-Control-Allow-Credentials", "true");
  }
  return response;
}

export function proxy(request: NextRequest) {
  if (request.method === "OPTIONS") {
    return withOpenCors(request, new NextResponse(null, { status: 204 }));
  }

  return withOpenCors(request, NextResponse.next());
}
