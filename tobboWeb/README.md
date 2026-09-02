# tobboWeb

Public web app for shared Tobbo polls. Opening `https://tobbo.app/p/{code}` lets someone vote anonymously without installing the app.

## Pages

- `/` — branded landing
- `/p/{code}` — load the poll, vote once, then see results

Identity is created with `POST /api/v1/anonymous` and stored in `localStorage`, matching the mobile app.

## Setup

```bash
cd tobboWeb
cp .env.example .env.local
npm install
npm run dev
```

Open [http://localhost:3000/p/YOURCODE](http://localhost:3000/p/YOURCODE).

## Environment

| Variable | Default | Purpose |
|---|---|---|
| `NEXT_PUBLIC_API_BASE_URL` | `https://tobbo-anonymously.onrender.com` | Tobbo API |
| `NEXT_PUBLIC_SITE_URL` | `https://tobbo.app` | Canonical URL for Open Graph tags |
