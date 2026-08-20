type EmptyStateProps = {
  title: string;
  message: string;
  actionLabel?: string;
  onAction?: () => void;
};

export function EmptyState({ title, message, actionLabel, onAction }: EmptyStateProps) {
  return (
    <div>
      <h1 className="question">{title}</h1>
      <p className="meta">{message}</p>
      {actionLabel && onAction ? (
        <button type="button" className="btn btn-primary mt-lg" onClick={onAction}>
          {actionLabel}
        </button>
      ) : null}
    </div>
  );
}
