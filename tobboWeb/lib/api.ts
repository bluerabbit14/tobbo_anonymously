import { API_BASE_URL } from "./config";
import { ApiError, type AnonymousToken, type PollDetail, type PollResults, type PollStatus } from "./types";

type RequestOptions = {
  method?: "GET" | "POST";
  body?: unknown;
  token?: string;
};

export function normalizePublicCode(code: string): string {
  return code.trim().toUpperCase();
}

export async function request<T>(path: string, options: RequestOptions = {}): Promise<T> {
  const { method = "GET", body, token } = options;
  const headers: Record<string, string> = {
    Accept: "application/json",
  };

  if (body !== undefined || method === "POST") {
    headers["Content-Type"] = "application/json";
  }
  if (token) {
    headers.Authorization = `Bearer ${token}`;
  }

  let response: Response;
  try {
    response = await fetch(`${API_BASE_URL}${path}`, {
      method,
      headers,
      body: body === undefined ? (method === "POST" ? "{}" : undefined) : JSON.stringify(body),
      signal: AbortSignal.timeout(25_000),
      cache: token ? "no-store" : "default",
    });
  } catch {
    throw new ApiError("Unable to reach Tobbo. Check your connection and try again.");
  }

  if (!response.ok) {
    throw await errorFrom(response);
  }

  if (response.status === 204) {
    return undefined as T;
  }

  const text = await response.text();
  if (!text) {
    return undefined as T;
  }

  return JSON.parse(text) as T;
}

async function errorFrom(response: Response): Promise<ApiError> {
  try {
    const decoded = (await response.json()) as { message?: string; code?: string };
    if (decoded.message) {
      return new ApiError(decoded.message, decoded.code, response.status);
    }
  } catch {
    /* ignore parse errors */
  }
  if (response.status === 404) {
    return new ApiError("We couldn't load this question.", "POLL_NOT_FOUND", 404);
  }
  return new ApiError("Something went wrong.", undefined, response.status);
}

export function createAnonymousSession(): Promise<AnonymousToken> {
  return request<AnonymousToken>("/api/v1/anonymous", { method: "POST" });
}

function parseStatus(value: unknown): PollStatus {
  const raw = String(value ?? "active").toLowerCase();
  if (raw === "closed" || raw === "expired") return raw;
  return "active";
}

export async function getPoll(code: string, token?: string): Promise<PollDetail> {
  const poll = await request<PollDetail>(
    `/api/v1/polls/${encodeURIComponent(normalizePublicCode(code))}`,
    { token },
  );
  return {
    ...poll,
    options: poll.options ?? [],
    voteCount: poll.voteCount ?? 0,
    hasVoted: Boolean(poll.hasVoted),
    status: parseStatus(poll.status),
  };
}

export function vote(code: string, optionId: string, token: string): Promise<void> {
  return request<void>(`/api/v1/polls/${encodeURIComponent(normalizePublicCode(code))}/votes`, {
    method: "POST",
    body: { optionId },
    token,
  });
}

export async function getResults(code: string, token?: string): Promise<PollResults> {
  const results = await request<PollResults>(
    `/api/v1/polls/${encodeURIComponent(normalizePublicCode(code))}/results`,
    { token },
  );
  return {
    ...results,
    question: results.question ?? "",
    totalVotes: results.totalVotes ?? 0,
    options: results.options ?? [],
    myVoteOptionId: results.myVoteOptionId ?? null,
  };
}
