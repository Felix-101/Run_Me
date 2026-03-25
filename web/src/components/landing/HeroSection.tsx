import container1Hero from "../../../assets/image/container_1.png";
import downloadIcon from "../../../assets/icons/download_icon.svg";
import appleIcon from "../../../assets/icons/apple_icon_svg.svg";
import googleIcon from "../../../assets/icons/google_icon_svg.svg";
import Navbar from "./Navbar";
import StoreBadge from "./StoreBadge";

export default function HeroSection() {
  return (
    <section className="relative overflow-hidden bg-black">
      <div
        aria-hidden
        className="pointer-events-none absolute inset-0 bg-[radial-gradient(circle_at_20%_0%,rgba(34,197,94,0.28),transparent_52%),radial-gradient(circle_at_80%_10%,rgba(163,230,53,0.10),transparent_45%)]"
      />

      <Navbar />

      <div className="relative z-10 mx-auto w-full max-w-7xl px-6 pb-12 pt-12 md:pb-16 md:pt-16">
        <div className="grid items-center gap-10 md:grid-cols-2">
          <div>
            <div className="inline-flex items-center gap-2 rounded-full bg-green-400/10 px-4 py-2 text-[11px] font-semibold tracking-wide text-green-300 ring-1 ring-green-400/20">
              THE FULL CAMPUS EXPERIENCE IS ON MOBILE
            </div>

            <h2 className="mt-6 text-5xl font-bold leading-tight text-white md:text-6xl">
              Lend a hand, build a{" "}
              <span className="bg-gradient-to-r from-green-400 to-lime-300 bg-clip-text text-transparent">
                future
              </span>
            </h2>

            <p className="mt-5 max-w-xl text-base leading-relaxed text-white/65">
              The easiest way for Nigerian students to access quick funds. Join thousands of students
              getting funded daily on the RunMe mobile app.
            </p>

            <div className="mt-8 flex flex-col gap-4 sm:flex-row sm:items-center">
              <a
                className="inline-flex items-center justify-center gap-2 rounded-2xl bg-green-400 px-6 py-3 text-sm font-semibold text-black hover:bg-green-300"
                href="#download"
              >
                <img alt="" className="h-5 w-5 object-contain" src={downloadIcon} />
                Download to Start
              </a>
              <a
                className="inline-flex justify-center rounded-2xl bg-white/5 px-6 py-3 text-sm font-semibold text-white ring-1 ring-white/10 hover:bg-white/10"
                href="#for-students"
              >
                Invest in Students
              </a>
            </div>

            <div className="mt-6 flex flex-col gap-3 sm:flex-row">
              <StoreBadge iconSrc={appleIcon} topText="DOWNLOAD ON" bottomText="App Store" />
              <StoreBadge iconSrc={googleIcon} topText="GET IT ON" bottomText="Google Play" />
            </div>
          </div>

          <div className="relative md:justify-self-end md:pl-10">
            <div className="absolute -inset-12 opacity-70 bg-[radial-gradient(circle_at_35%_35%,rgba(34,197,94,0.18),transparent_65%)] blur-2xl" />
            <img
              alt="RunMe app preview"
              className="relative mx-auto w-full max-w-sm drop-shadow-2xl md:max-w-md lg:max-w-lg"
              loading="lazy"
              decoding="async"
              src={container1Hero}
            />
          </div>
        </div>
      </div>
    </section>
  );
}
