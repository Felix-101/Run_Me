export default function LandingPage() {
  return (
    <div className="min-h-screen bg-slate-50 text-slate-900">
      <header className="mx-auto max-w-5xl p-6">
        <h1 className="text-3xl font-semibold">RunMe</h1>
        <p className="mt-2 text-slate-600">
          Landing page placeholder. Drop in your provided design here.
        </p>
      </header>

      <main className="mx-auto max-w-5xl p-6">
        <div className="rounded-xl border bg-white p-6">
          <h2 className="text-xl font-medium">What is RunMe?</h2>
          <p className="mt-2 text-slate-600">
            This is a scaffolded frontend. Once you share the design, I’ll wire the layout and components.
          </p>

          <div className="mt-6 flex gap-3">
            <a
              className="rounded-lg bg-slate-900 px-4 py-2 text-white"
              href="/login"
            >
              Login
            </a>
          </div>
        </div>
      </main>
    </div>
  );
}

