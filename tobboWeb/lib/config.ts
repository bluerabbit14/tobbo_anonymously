export const API_BASE_URL = (
  process.env.NEXT_PUBLIC_API_BASE_URL ??
  "https://tobbo-anonymously.onrender.com"
).replace(/\/$/, "");

export const SITE_URL = (
  process.env.NEXT_PUBLIC_SITE_URL ?? "https://tobbo.app"
).replace(/\/$/, "");

export const PLAY_STORE_URL = process.env.NEXT_PUBLIC_PLAY_STORE_URL?.trim() || "";
export const APP_STORE_URL = process.env.NEXT_PUBLIC_APP_STORE_URL?.trim() || "";
