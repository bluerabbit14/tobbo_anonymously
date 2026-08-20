"use client";

import { getPoll, getResults, vote as postVote } from "./api";
import { ensureSession, refreshSession } from "./session";
import { ApiError, type PollDetail, type PollResults } from "./types";

async function withAuth<T>(fn: (token: string) => Promise<T>, retried = false): Promise<T> {
  const token = await ensureSession();
  try {
    return await fn(token);
  } catch (error) {
    if (error instanceof ApiError && error.status === 401 && !retried) {
      await refreshSession();
      return withAuth(fn, true);
    }
    throw error;
  }
}

export function loadPoll(code: string): Promise<PollDetail> {
  return withAuth((token) => getPoll(code, token));
}

export function loadResults(code: string): Promise<PollResults> {
  return withAuth((token) => getResults(code, token));
}

export function submitVote(code: string, optionId: string): Promise<void> {
  return withAuth((token) => postVote(code, optionId, token));
}
