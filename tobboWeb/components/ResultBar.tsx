import type { CSSProperties } from "react";

type ResultBarProps = {
  text: string;
  voteCount: number;
  percentage: number;
  marked?: boolean;
};

export function ResultBar({ text, voteCount, percentage, marked = false }: ResultBarProps) {
  const rounded = Math.round(percentage);
  const width = `${Math.max(0, Math.min(percentage, 100))}%`;
  return (
    <div className={marked ? "result is-marked" : "result"} aria-current={marked || undefined}>
      <div className="result-top">
        <p className="result-label">{text}</p>
        <p className="result-pct">{rounded}%</p>
      </div>
      <div className="result-track">
        <div className="result-fill" style={{ ["--pct"]: width } as CSSProperties} />
      </div>
      <p className="result-count">
        {voteCount} {voteCount === 1 ? "vote" : "votes"}
      </p>
    </div>
  );
}
