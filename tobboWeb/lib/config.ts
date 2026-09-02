function envUrl(value: string | undefined, fallback: string): string {
  const trimmed = value?.trim();
  if (trimmed) return trimmed.replace(/\/$/, "");
  return fallback.replace(/\/$/, "");
}

function vercelSiteUrl(): string | undefined {
  const host = (
    process.env.VERCEL_PROJECT_PRODUCTION_URL ||
    process.env.NEXT_PUBLIC_VERCEL_URL ||
    process.env.VERCEL_URL
  )?.trim();
  if (!host) return undefined;
  if (host.startsWith("http://") || host.startsWith("https://")) {
    return host.replace(/\/$/, "");
  }
  return `https://${host.replace(/\/$/, "")}`;
}

export const API_BASE_URL = envUrl(
  process.env.NEXT_PUBLIC_API_BASE_URL,
  "https://tobbo-anonymously.onrender.com"
);

export const SITE_URL = envUrl(
  process.env.NEXT_PUBLIC_SITE_URL,
  vercelSiteUrl() ?? "https://tobbo.app"
);
