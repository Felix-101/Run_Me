export default function TrustedBySection() {
  return (
    <section className="border-t border-white/[0.06] bg-black" aria-label="Trusted partners">
      <div className="mx-auto w-full max-w-7xl px-6 py-12 md:py-14">
        <p className="text-center text-[11px] font-semibold uppercase tracking-[0.22em] text-white/45">
          Trusted by
        </p>
        <div className="mt-8 flex flex-col items-center justify-center gap-12 sm:flex-row sm:gap-16 md:gap-28">
          <div className="flex h-16 items-center justify-center md:h-20">
            <img
              src="/trusted/enyata.png"
              alt="Enyata"
              className="max-h-14 w-auto max-w-[min(100%,220px)] object-contain md:max-h-16"
              width={220}
              height={80}
              loading="lazy"
              decoding="async"
            />
          </div>
          <div className="flex h-16 items-center justify-center md:h-20">
            <img
              src="/trusted/interswitch.png"
              alt="Interswitch"
              className="max-h-14 w-auto max-w-[min(100%,280px)] object-contain md:max-h-16"
              width={280}
              height={72}
              loading="lazy"
              decoding="async"
            />
          </div>
        </div>
        <p className="mt-10 text-center text-xs text-white/40">
          Partnering for the Enyata × Interswitch Buildathon 2026
        </p>
      </div>
    </section>
  );
}
