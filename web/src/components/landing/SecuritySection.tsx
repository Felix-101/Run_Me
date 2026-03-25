export default function SecuritySection() {
  return (
    <section id="privacy" className="bg-black">
      <div className="mx-auto w-full max-w-7xl px-6 pb-16">
        <div className="rounded-3xl border border-white/10 bg-white/5 p-10 md:p-14">
          <div className="grid gap-10 md:grid-cols-2 md:items-center">
            <div>
              <div className="text-4xl font-extrabold text-white">Secure Funds, Zero Stress.</div>
              <p className="mt-4 max-w-md text-sm leading-relaxed text-white/60">
                We use state-of-the-art encryption and bank-level verification in our app to ensure every
                Naira is safe and every student is real.
              </p>

              <div className="mt-8 space-y-6">
                <div className="flex gap-4">
                  <div className="mt-1 flex h-12 w-12 items-center justify-center rounded-2xl bg-green-400/10 ring-1 ring-green-400/20">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
                      <path
                        d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10Z"
                        stroke="#86efac"
                        strokeWidth="2"
                        strokeLinejoin="round"
                      />
                      <path
                        d="M9.5 12l1.8 1.8 3.7-4.3"
                        stroke="#86efac"
                        strokeWidth="2"
                        strokeLinecap="round"
                        strokeLinejoin="round"
                      />
                    </svg>
                  </div>
                  <div>
                    <div className="text-sm font-extrabold text-white">BVN Protection</div>
                    <div className="mt-1 text-xs leading-relaxed text-white/60">
                      Secure identity verification through NIBSS standard protocols.
                    </div>
                  </div>
                </div>

                <div className="flex gap-4">
                  <div className="mt-1 flex h-12 w-12 items-center justify-center rounded-2xl bg-green-400/10 ring-1 ring-green-400/20">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
                      <path
                        d="M12 2l7 4v6c0 5-3 10-7 10S5 17 5 12V6l7-4Z"
                        stroke="#86efac"
                        strokeWidth="2"
                        strokeLinejoin="round"
                      />
                      <path d="M9 12h6" stroke="#86efac" strokeWidth="2" strokeLinecap="round" />
                    </svg>
                  </div>
                  <div>
                    <div className="text-sm font-extrabold text-white">NDPR Compliant</div>
                    <div className="mt-1 text-xs leading-relaxed text-white/60">
                      Your personal data is managed according to Nigerian data regulations.
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <div className="space-y-4">
              {[
                { title: "Biometric Login", subtitle: "Secure App access" },
                { title: "Fraud Filter", subtitle: "Real-time portal check" },
              ].map((item) => (
                <div
                  key={item.title}
                  className="flex items-center justify-between rounded-2xl bg-black/35 px-5 py-4 ring-1 ring-white/10"
                >
                  <div className="flex items-center gap-3">
                    <div className="flex h-10 w-10 items-center justify-center rounded-2xl bg-green-400/10 ring-1 ring-green-400/20">
                      <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
                        <path d="M12 3v6" stroke="#86efac" strokeWidth="2" strokeLinecap="round" />
                        <path d="M8 7h8" stroke="#86efac" strokeWidth="2" strokeLinecap="round" />
                        <path
                          d="M7 12c1.5-2 3.2-3 5-3s3.5 1 5 3v6H7v-6Z"
                          stroke="#86efac"
                          strokeWidth="2"
                          strokeLinejoin="round"
                        />
                      </svg>
                    </div>
                    <div>
                      <div className="text-sm font-extrabold text-white">{item.title}</div>
                      <div className="text-xs text-white/60">{item.subtitle}</div>
                    </div>
                  </div>
                  <div className="rounded-full bg-green-400 px-3 py-1 text-xs font-extrabold text-black">
                    ACTIVE
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
