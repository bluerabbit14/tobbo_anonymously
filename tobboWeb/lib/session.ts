"use client";

import { createAnonymousSession } from "./api";

const TOKEN_KEY = "tobbo_access_token";
const EXPIRES_KEY = "tobbo_token_expires_at";
const USER_ID_KEY = "tobbo_anonymous_user_id";

let ensuring: Promise<string> | null = null;

function read(key: string): string | null {
  if (typeof window === "undefined") return null;
  return window.localStorage.getItem(key);
}

function write(key: string, value: string) {
  window.localStorage.setItem(key, value);
}

function remove(key: string) {
  window.localStorage.removeItem(key);
}

export function getValidToken(): string | null {
  const token = read(TOKEN_KEY);
  const expires = read(EXPIRES_KEY);
  if (!token || !expires) return null;
  const expiresAt = Date.parse(expires);
  if (Number.isNaN(expiresAt)) return null;
  const bufferMs = 60_000;
  if (expiresAt <= Date.now() + bufferMs) return null;
  return token;
}

export function clearSession() {
  remove(TOKEN_KEY);
  remove(EXPIRES_KEY);
  remove(USER_ID_KEY);
}

async function createSession(): Promise<string> {
  const existing = getValidToken();
  if (existing) return existing;

  const response = await createAnonymousSession();
  write(TOKEN_KEY, response.accessToken);
  write(EXPIRES_KEY, response.expiresAt);
  if (response.userId) {
    write(USER_ID_KEY, response.userId);
  }
  return response.accessToken;
}

export async function ensureSession(): Promise<string> {
  const existing = getValidToken();
  if (existing) return existing;
  if (ensuring) return ensuring;

  const pending = createSession().finally(() => {
    if (ensuring === pending) ensuring = null;
  });
  ensuring = pending;
  return pending;
}

export async function refreshSession(): Promise<string> {
  clearSession();
  return ensureSession();
}
