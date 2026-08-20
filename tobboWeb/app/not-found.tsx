import Image from "next/image";
import Link from "next/link";

export default function NotFound() {
  return (
    <div className="page">
      <main className="sheet">
        <Link href="/" className="logo-row">
          <Image src="/tobbo-icon.png" alt="Tobbo" width={36} height={36} />
          <span className="brand-wordmark" style={{ margin: 0 }}>
            Tobbo
          </span>
        </Link>
        <h1 className="question">Page not found.</h1>
        <p className="meta">This link doesn’t go anywhere. Open a shared question, or get the Tobbo app.</p>
        <Link href="/" className="btn btn-primary mt-xl">
          Back to Tobbo
        </Link>
      </main>
    </div>
  );
}
