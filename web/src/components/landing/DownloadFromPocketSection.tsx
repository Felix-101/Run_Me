import phoneContainer from "../../../assets/image/phone_container.png";
import appleIcon from "../../../assets/icons/apple_icon_svg.svg";
import googleIcon from "../../../assets/icons/google_icon_svg.svg";
import StoreBadge from "./StoreBadge";

export default function DownloadFromPocketSection() {
  return (
    <section id="download" className="bg-black">
      <div className="mx-auto w-full max-w-7xl px-6 pb-16">
        <div className="relative overflow-hidden rounded-3xl border border-white/10 bg-[#121212] p-8 md:p-12">
          <div
            aria-hidden
            className="pointer-events-none absolute -top-24 right-0 h-[28rem] w-[70%] bg-[radial-gradient(ellipse_at_top_right,rgba(34,197,94,0.35),transparent_65%)]"
          />
          <div
            aria-hidden
            className="pointer-events-none absolute -top-8 right-[8%] h-64 w-64 opacity-[0.07]"
          >
            <svg viewBox="0 0 120 80" className="h-full w-full text-white" fill="none">
              <rect x="8" y="16" width="104" height="56" rx="8" stroke="currentColor" strokeWidth="2" />
              <rect x="52" y="8" width="16" height="12" rx="2" stroke="currentColor" strokeWidth="2" />
              <circle cx="32" cy="44" r="10" stroke="currentColor" strokeWidth="2" />
              <path d="M52 38h48M52 50h36" stroke="currentColor" strokeWidth="2" strokeLinecap="round" />
            </svg>
          </div>

          <div className="relative grid items-center gap-10 md:grid-cols-2 md:gap-12">
            <div className="relative z-10">
              <div className="text-4xl font-extrabold leading-tight text-white md:text-[2.5rem]">
                Run your degree
                <br />
                <span className="bg-gradient-to-r from-green-400 to-lime-300 bg-clip-text text-transparent">
                  from your pocket
                </span>
              </div>

              <p className="mt-4 max-w-md text-sm leading-relaxed text-white/60">
                Get the full RunMe experience. Real-time notifications, faster disbursements, and exclusive
                student rewards only on the mobile app.
              </p>

              <div className="mt-8 flex flex-col gap-3 sm:flex-row sm:flex-wrap">
                <StoreBadge iconSrc={appleIcon} topText="DOWNLOAD ON" bottomText="App Store" />
                <StoreBadge iconSrc={googleIcon} topText="GET IT ON" bottomText="Google Play" />
              </div>
            </div>

            <div className="relative flex min-h-[280px] items-center justify-center md:min-h-[360px]">
              <div className="absolute inset-0 bg-[radial-gradient(circle_at_50%_45%,rgba(34,197,94,0.35),transparent_55%)] blur-3xl" />
              <img
                alt="RunMe app on a phone"
                className="relative z-[1] mx-auto h-auto w-full max-w-[min(100%,280px)] object-contain drop-shadow-[0_0_60px_rgba(74,222,128,0.25)] md:max-w-[min(100%,320px)]"
                loading="lazy"
                decoding="async"
                src={phoneContainer}
              />
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
