import kycCardGraphic from "../../../assets/image/container_3.png";
import listNeedIllustration from "../../../assets/image/image_container.png";

function WalletFlowIcons() {
  return (
    <div className="flex items-center gap-3">
      <span className="flex h-10 w-10 items-center justify-center rounded-xl bg-black/15 text-black">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" aria-hidden>
          <path
            d="M3 21h18M5 21V7l8-4v18M19 21V11l-6-4"
            stroke="currentColor"
            strokeWidth="1.75"
            strokeLinecap="round"
            strokeLinejoin="round"
          />
          <path d="M9 9v.01" stroke="currentColor" strokeWidth="2" strokeLinecap="round" />
        </svg>
      </span>
      <span className="flex h-10 w-10 items-center justify-center rounded-xl bg-black/15 text-black">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" aria-hidden>
          <path
            d="M17 1l4 4-4 4"
            stroke="currentColor"
            strokeWidth="1.75"
            strokeLinecap="round"
            strokeLinejoin="round"
          />
          <path
            d="M3 11V9a4 4 0 014-4h14"
            stroke="currentColor"
            strokeWidth="1.75"
            strokeLinecap="round"
            strokeLinejoin="round"
          />
          <path
            d="M7 23l-4-4 4-4"
            stroke="currentColor"
            strokeWidth="1.75"
            strokeLinecap="round"
            strokeLinejoin="round"
          />
          <path
            d="M21 13v2a4 4 0 01-4 4H3"
            stroke="currentColor"
            strokeWidth="1.75"
            strokeLinecap="round"
            strokeLinejoin="round"
          />
        </svg>
      </span>
      <span className="flex h-10 w-10 items-center justify-center rounded-xl bg-black/15 text-black">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" aria-hidden>
          <path
            d="M2 9l10-5 10 5-10 5L2 9z"
            stroke="currentColor"
            strokeWidth="1.75"
            strokeLinejoin="round"
          />
          <path d="M6 11.5V16c0 1 4 3 8 3s8-2 8-3v-4.5" stroke="currentColor" strokeWidth="1.75" />
        </svg>
      </span>
    </div>
  );
}

export default function CampusLifeSection() {
  return (
    <section id="how-it-works" className="relative overflow-hidden bg-black">
      <div
        aria-hidden
        className="pointer-events-none absolute inset-0 bg-[radial-gradient(circle_at_70%_20%,rgba(34,197,94,0.18),transparent_50%)]"
      />

      <div className="relative mx-auto w-full max-w-7xl px-6 py-16">
        <div className="text-center">
          <h2 className="font-heading text-4xl font-bold text-white md:text-[2.5rem] md:leading-tight">
            Designed for Campus Life
          </h2>
          <p className="mx-auto mt-4 max-w-2xl font-sans text-base text-white/60">
            Skip the bank queues. RunMe connects you to capital that understands the Nigerian academic
            journey.
          </p>
        </div>

        <div className="mt-12 grid grid-cols-1 gap-6 md:grid-cols-2">
          {/* 01 */}
          <div className="relative overflow-hidden rounded-2xl border border-white/10 bg-[#141414] p-7">
            <img
              alt=""
              aria-hidden
              className="pointer-events-none absolute -right-2 top-1/2 h-56 w-auto max-w-[55%] -translate-y-1/2 opacity-[0.18] object-contain object-right md:h-64 md:opacity-20"
              src={kycCardGraphic}
            />
            <div className="relative z-10">
              <div className="font-heading text-6xl font-bold text-green-400/25">01</div>
              <h3 className="font-heading mt-1 text-lg font-bold text-white">Matric No. &amp; KYC</h3>
              <p className="mt-2 font-sans text-sm leading-relaxed text-white/60">
                Verification is seamless in-app. Connect your school portal and BVN. Our RunScore™
                evaluates your academic consistency alongside your financial needs.
              </p>
              <div className="mt-5 flex flex-wrap gap-2">
                {["Academic Records", "BVN Verified", "Portal Sync"].map((t) => (
                  <span
                    key={t}
                    className="rounded-full bg-black/40 px-3 py-1 text-xs font-medium text-white/75 ring-1 ring-white/10"
                  >
                    {t}
                  </span>
                ))}
              </div>
            </div>
          </div>

          {/* 02 */}
          <div className="rounded-2xl border border-white/10 bg-[#141414] p-7">
            <div className="font-heading text-6xl font-bold text-green-400/25">02</div>
            <h3 className="font-heading mt-1 text-lg font-bold text-white">List Your Need</h3>
            <p className="mt-2 font-sans text-sm leading-relaxed text-white/60">
              School fees, hostel rent, or project materials? State your amount and let the community
              support you directly from your mobile.
            </p>
            <div className="mt-5">
              <img
                alt=""
                className="h-40 w-full rounded-2xl object-cover object-center grayscale opacity-90 ring-1 ring-white/10"
                loading="lazy"
                decoding="async"
                src={listNeedIllustration}
              />
            </div>
          </div>

          {/* 03 */}
          <div className="rounded-2xl border border-white/10 bg-[#141414] p-7">
            <div className="font-heading text-6xl font-bold text-green-400/25">03</div>
            <h3 className="font-heading mt-1 text-lg font-bold text-white">Fund &amp; Disburse</h3>
            <p className="mt-2 font-sans text-sm leading-relaxed text-white/60">
              Lenders fund your campaign. Once successful, funds are transferred instantly to your in-app
              wallet.
            </p>
            <div className="mt-6 flex items-center">
              <div className="flex -space-x-2">
                <span className="relative z-30 inline-flex h-9 w-9 rounded-full bg-zinc-600 ring-2 ring-[#141414]" />
                <span className="relative z-20 inline-flex h-9 w-9 rounded-full bg-green-500 ring-2 ring-[#141414]" />
                <span className="relative z-10 inline-flex h-9 w-9 rounded-full bg-teal-500 ring-2 ring-[#141414]" />
              </div>
              <span className="ml-3 font-sans text-xs font-semibold text-green-300">+25</span>
            </div>
          </div>

          {/* 04 */}
          <div className="flex flex-col gap-6 rounded-2xl border border-lime-400/30 bg-[#b8f63a] p-7 text-black md:flex-row md:items-stretch md:justify-between">
            <div className="min-w-0 flex-1">
              <div className="font-heading text-6xl font-bold text-[#1a3d0a]/35">04</div>
              <h3 className="font-heading mt-1 text-lg font-bold text-black">Graduate &amp; Repay</h3>
              <p className="mt-2 font-sans text-sm leading-relaxed text-black/75">
                Start small repayments during NYSC or when you land your first job. Managed automatically
                via your app profile.
              </p>
            </div>
            <div className="flex shrink-0 flex-col justify-center rounded-2xl bg-black/10 px-4 py-3 ring-1 ring-black/10">
              <div className="text-[10px] font-bold uppercase tracking-[0.2em] text-black/55">
                Wallet flow
              </div>
              <div className="mt-3">
                <WalletFlowIcons />
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
