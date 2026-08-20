"use client";

import Link from "next/link";
import { APP_STORE_URL, PLAY_STORE_URL } from "@/lib/config";

type GetAppCtaProps = {
  variant?: "primary" | "secondary" | "cream";
  label?: string;
  /** When store URLs are unset, link to `/`. Disable on the home page. */
  homeFallback?: boolean;
};

function buttonClass(variant: GetAppCtaProps["variant"]) {
  if (variant === "cream") return "btn btn-cream";
  if (variant === "secondary") return "btn btn-secondary";
  return "btn btn-primary";
}

export function GetAppCta({
  variant = "primary",
  label = "Get Tobbo",
  homeFallback = true,
}: GetAppCtaProps) {
  const className = buttonClass(variant);

  if (APP_STORE_URL && PLAY_STORE_URL) {
    return (
      <div className="store-row">
        <a className={className} href={APP_STORE_URL} target="_blank" rel="noopener noreferrer">
          App Store
        </a>
        <a className="btn btn-secondary" href={PLAY_STORE_URL} target="_blank" rel="noopener noreferrer">
          Google Play
        </a>
      </div>
    );
  }

  const href = APP_STORE_URL || PLAY_STORE_URL;
  if (href) {
    return (
      <a className={className} href={href} target="_blank" rel="noopener noreferrer">
        {label}
      </a>
    );
  }

  if (homeFallback) {
    return (
      <Link className={className} href="/">
        {label}
      </Link>
    );
  }

  return (
    <span className={className} aria-disabled="true">
      {label}
    </span>
  );
}
