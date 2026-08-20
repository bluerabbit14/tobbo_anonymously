export type PollStatus = "active" | "closed" | "expired";

export type PollOption = {
  id: string;
  text: string;
};

export type PollDetail = {
  publicCode: string;
  question: string;
  options: PollOption[];
  voteCount: number;
  distanceKm: number | null;
  hasVoted: boolean;
  status: PollStatus;
};

export type PollResultOption = {
  id: string;
  text: string;
  voteCount: number;
  percentage: number;
};

export type PollResults = {
  question: string;
  totalVotes: number;
  options: PollResultOption[];
  myVoteOptionId: string | null;
};

export type AnonymousToken = {
  accessToken: string;
  expiresAt: string;
  userId: string;
};

export class ApiError extends Error {
  readonly code?: string;
  readonly status?: number;

  constructor(message: string, code?: string, status?: number) {
    super(message);
    this.name = "ApiError";
    this.code = code;
    this.status = status;
  }
}

export function isClosedStatus(status: PollStatus): boolean {
  return status === "closed" || status === "expired";
}
