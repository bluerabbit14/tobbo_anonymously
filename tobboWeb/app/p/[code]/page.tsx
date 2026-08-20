import type { Metadata } from "next";
import { PollVoteView } from "@/components/PollVoteView";
import { getPoll } from "@/lib/api";
import { SITE_URL } from "@/lib/config";
import { ApiError } from "@/lib/types";

export const revalidate = 30;

type PollPageProps = {
  params: Promise<{ code: string }>;
};

async function loadPublicPoll(code: string) {
  try {
    return await getPoll(code);
  } catch (error) {
    if (error instanceof ApiError && (error.code === "POLL_NOT_FOUND" || error.status === 404)) {
      return null;
    }
    return null;
  }
}

export async function generateMetadata({ params }: PollPageProps): Promise<Metadata> {
  const { code } = await params;
  const poll = await loadPublicPoll(code);
  if (!poll) {
    return {
      title: "Question not found",
      description: "This Tobbo question is unavailable.",
    };
  }

  const title = poll.question;
  const description = "Vote anonymously on Tobbo.";
  const url = `${SITE_URL}/p/${poll.publicCode}`;

  return {
    title,
    description,
    openGraph: {
      title,
      description,
      url,
      siteName: "Tobbo",
      type: "website",
      images: [{ url: "/tobbo-icon.png", width: 512, height: 512, alt: "Tobbo" }],
    },
    twitter: {
      card: "summary",
      title,
      description,
      images: ["/tobbo-icon.png"],
    },
  };
}

export default async function PollPage({ params }: PollPageProps) {
  const { code } = await params;
  return <PollVoteView code={code} />;
}
