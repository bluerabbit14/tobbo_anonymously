import Image from "next/image";
import { TryTobboButton } from "@/components/TryTobboButton";

export default function HomePage() {
  return (
    <div className="page page--brand">
      <main className="home">
        <p className="home-kicker">Tobbo</p>
        <div>
          <Image src="/tobbo-icon.png" alt="" width={72} height={72} style={{ borderRadius: 16 }} />
          <h1 className="home-title" style={{ marginTop: 28 }}>
            Ask anything.
            <br />
            Get honest answers.
          </h1>
          <p className="home-lead">
            Get real opinions from real people — without revealing who you are.
          </p>
          <p className="home-tag">Ask. Vote. Decide.</p>
        </div>
        <div>
          <TryTobboButton className="btn btn-cream" />
          <p className="home-foot">Your identity stays private.</p>
        </div>
      </main>
    </div>
  );
}
