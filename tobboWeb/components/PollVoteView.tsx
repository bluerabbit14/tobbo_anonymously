"use client";

import Image from "next/image";
import Link from "next/link";
import { useEffect, useState } from "react";
import { EmptyState } from "@/components/EmptyState";
import { OptionTile } from "@/components/OptionTile";
import { ResultBar } from "@/components/ResultBar";
import { TobboLoader, TobboLoadingOverlay } from "@/components/TobboLoader";
import { loadPoll, loadResults, submitVote } from "@/lib/client-api";
import { ApiError, isClosedStatus, type PollDetail, type PollResults } from "@/lib/types";

type PollVoteViewProps = {
  code: string;
};

type ViewState =
  | { kind: "loading" }
  | { kind: "error"; message: string }
  | { kind: "missing"; message: string }
  | {
      kind: "vote";
      poll: PollDetail;
      selectedId: string | null;
      voting: boolean;
      error: string | null;
    }
  | { kind: "results"; poll: PollDetail; results: PollResults; closed: boolean };

function votedOptionText(results: PollResults): string | null {
  if (!results.myVoteOptionId) return null;
  return results.options.find((option) => option.id === results.myVoteOptionId)?.text ?? null;
}

export function PollVoteView({ code }: PollVoteViewProps) {
  const [state, setState] = useState<ViewState>({ kind: "loading" });
  const [reloadKey, setReloadKey] = useState(0);

  useEffect(() => {
    let cancelled = false;

    async function run() {
      try {
        const poll = await loadPoll(code);
        if (cancelled) return;
        const closed = isClosedStatus(poll.status);
        if (poll.hasVoted || closed) {
          const results = await loadResults(code);
          if (cancelled) return;
          setState({ kind: "results", poll, results, closed });
          return;
        }
        setState({ kind: "vote", poll, selectedId: null, voting: false, error: null });
      } catch (error) {
        if (cancelled) return;
        if (error instanceof ApiError && (error.code === "POLL_NOT_FOUND" || error.status === 404)) {
          setState({
            kind: "missing",
            message: error.message || "We couldn't load this question.",
          });
          return;
        }
        setState({
          kind: "error",
          message: error instanceof Error ? error.message : "Something went wrong.",
        });
      }
    }

    void run();
    return () => {
      cancelled = true;
    };
  }, [code, reloadKey]);

  function retry() {
    setState({ kind: "loading" });
    setReloadKey((key) => key + 1);
  }

  async function handleVote() {
    if (state.kind !== "vote" || !state.selectedId || state.voting) return;
    const { poll, selectedId } = state;
    setState({ ...state, voting: true, error: null });
    try {
      try {
        await submitVote(code, selectedId);
      } catch (error) {
        if (!(error instanceof ApiError) || (error.code !== "ALREADY_VOTED" && error.code !== "POLL_CLOSED")) {
          throw error;
        }
      }
      const [latestPoll, results] = await Promise.all([loadPoll(code), loadResults(code)]);
      setState({
        kind: "results",
        poll: latestPoll,
        results,
        closed: isClosedStatus(latestPoll.status),
      });
    } catch (error) {
      setState({
        kind: "vote",
        poll,
        selectedId,
        voting: false,
        error: error instanceof Error ? error.message : "Something went wrong.",
      });
    }
  }

  return (
    <div className="page">
      <main className="sheet">
        <p className="eyebrow">Shared question</p>
        <Link href="/" className="logo-row">
          <Image src="/tobbo-icon.png" alt="Tobbo" width={36} height={36} />
          <span className="brand-wordmark" style={{ margin: 0 }}>
            Tobbo
          </span>
        </Link>

        {state.kind === "loading" ? <TobboLoader /> : null}

        {state.kind === "error" ? (
          <EmptyState
            title="Something went wrong."
            message={state.message}
            actionLabel="Try again"
            onAction={retry}
          />
        ) : null}

        {state.kind === "missing" ? (
          <EmptyState
            title="We couldn't find this question."
            message={state.message}
            actionLabel="Try again"
            onAction={retry}
          />
        ) : null}

        {state.kind === "vote" ? (
          <>
            <h1 className="question">{state.poll.question}</h1>
            <p className="meta">{state.poll.voteCount} people have voted</p>
            <div className="mt-xl">
              {state.poll.options.map((option, index) => (
                <OptionTile
                  key={option.id}
                  index={index}
                  text={option.text}
                  selected={state.selectedId === option.id}
                  onSelect={() =>
                    setState((current) =>
                      current.kind === "vote" ? { ...current, selectedId: option.id } : current,
                    )
                  }
                />
              ))}
            </div>
            <p className="hint mt-md">Vote anonymously. No account required.</p>
            {state.error ? <p className="error-text mt-sm">{state.error}</p> : null}
            <button
              type="button"
              className="btn btn-primary mt-xl"
              disabled={!state.selectedId || state.voting}
              onClick={() => void handleVote()}
            >
              {state.voting ? "Voting…" : "Vote"}
            </button>
            {state.voting ? <TobboLoadingOverlay /> : null}
          </>
        ) : null}

        {state.kind === "results" ? <ResultsBody poll={state.poll} results={state.results} closed={state.closed} /> : null}
      </main>
    </div>
  );
}

function ResultsBody({
  poll,
  results,
  closed,
}: {
  poll: PollDetail;
  results: PollResults;
  closed: boolean;
}) {
  const choice = votedOptionText(results);
  const hasVoted = Boolean(results.myVoteOptionId);

  return (
    <>
      <h1 className="question">{results.question || poll.question}</h1>
      <p className="meta meta--caps mt-md">{results.totalVotes} people voted</p>
      {closed ? <p className="meta">This question has closed.</p> : null}

      {hasVoted && choice ? (
        <div className="mt-xl">
          <p className="voted-label">You’ve already voted</p>
          <p className="voted-choice mt-sm">{`You voted for:\n${choice}`}</p>
        </div>
      ) : null}

      <div className="mt-xl">
        {results.options.map((option) => (
          <ResultBar
            key={option.id}
            text={option.text}
            voteCount={option.voteCount}
            percentage={option.percentage}
            marked={option.id === results.myVoteOptionId}
          />
        ))}
      </div>

      <p className="hint">Your vote is anonymous.</p>
    </>
  );
}
