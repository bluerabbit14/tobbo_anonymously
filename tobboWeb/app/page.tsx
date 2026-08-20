import Image from "next/image";
import { GetAppCta } from "@/components/GetAppCta";

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
          <GetAppCta variant="cream" homeFallback={false} />
          <p className="home-foot">Your identity stays private.</p>
        </div>
      </main>
    </div>
  );
}
