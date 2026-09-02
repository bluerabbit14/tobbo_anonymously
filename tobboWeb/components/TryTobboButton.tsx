type TryTobboButtonProps = {
  className: string;
};

export function TryTobboButton({ className }: TryTobboButtonProps) {
  return (
    <a className={`btn-try ${className}`} href="/app-release.apk" download="tobbo.apk">
      <AndroidIcon />
      Try Tobbo
    </a>
  );
}

function AndroidIcon() {
  return (
    <svg viewBox="0 0 24 24" width="20" height="20" aria-hidden="true" focusable="false">
      <path
        fill="currentColor"
        d="M17.6 9.48 19.44 6.3a.64.64 0 0 0-.26-.85.64.64 0 0 0-.83.22l-1.88 3.24a11.43 11.43 0 0 0-8.94 0L5.65 5.67a.64.64 0 0 0-.83-.22.64.64 0 0 0-.26.85l1.84 3.18C4.3 11.17 3 13.42 3 16h18c0-2.58-1.3-4.83-3.4-6.52M6.5 13.5a1 1 0 1 1 0-2 1 1 0 0 1 0 2m11 0a1 1 0 1 1 0-2 1 1 0 0 1 0 2"
      />
    </svg>
  );
}
