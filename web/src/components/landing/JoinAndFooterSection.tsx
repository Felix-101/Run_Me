import appleIcon from "../../../assets/icons/apple_icon_svg.svg";
import googleIcon from "../../../assets/icons/google_icon_svg.svg";
import { useLandingToast } from "../LandingToastProvider";
import StoreBadge from "./StoreBadge";

export default function JoinAndFooterSection() {
  const { showToast } = useLandingToast();
  return (
    <footer id="ambassadors" className="bg-black">
      <div className="mx-auto w-full max-w-7xl px-6 pb-10 pt-12">
        <div className="text-center">
          <div className="text-4xl font-extrabold text-white">
            Ready to join the runme
            <br />
            movement?
          </div>
          <p className="mx-auto mt-4 max-w-2xl text-sm leading-relaxed text-white/55">
            Whether you&apos;re fixing your school fees or empowering the next
            genius, runme is where Nigerian excellence meets community capital.
          </p>

          <div className="mt-8 flex flex-col items-center gap-3 sm:flex-row sm:justify-center">
            <a
              className="inline-flex items-center justify-center rounded-2xl bg-green-400 px-7 py-3 text-sm font-extrabold text-black hover:bg-green-300"
              href="/login"
            >
              Create Your Mobile Wallet
            </a>
            <a
              className="inline-flex items-center justify-center rounded-2xl border border-white/15 bg-white/5 px-7 py-3 text-sm font-extrabold text-white hover:bg-white/10"
              href="#how-it-works"
            >
              Browse Student Projects
            </a>
          </div>
        </div>

        <div className="mt-14 border-t border-white/10 pt-10">
          <div className="grid gap-10 md:grid-cols-4">
            <div className="md:col-span-1">
              <div className="flex items-center gap-3">
                <img
                  alt="runme"
                  className="h-10 w-10 shrink-0 object-contain"
                  src="/favicon.svg"
                  width={40}
                  height={40}
                />
                <div className="text-sm font-semibold text-white">runme</div>
              </div>
              <div className="mt-4 text-sm leading-relaxed text-white/55">
                Empowering Nigerian students through peer support and
                transparent lending. No queues, just campus funds.
              </div>
            </div>

            <div>
              <div className="text-sm font-extrabold text-white">Solution</div>
              <div className="mt-3 space-y-2 text-sm text-white/60">
                <a href="#for-students" className="block hover:text-white">
                  For Students
                </a>
                <a href="#for-lenders" className="block hover:text-white">
                  For Alumni
                </a>
                <a href="#how-it-works" className="block hover:text-white">
                  Campus Reps
                </a>
              </div>
            </div>

            <div>
              <div className="text-sm font-extrabold text-white">Resources</div>
              <div className="mt-3 space-y-2 text-sm text-white/60">
                <a href="#privacy" className="block hover:text-white">
                  Privacy &amp; Data
                </a>
                <a href="#ambassadors" className="block hover:text-white">
                  Campus Ambassadors
                </a>
                <a href="#support" className="block hover:text-white">
                  Contact Support
                </a>
              </div>
            </div>

            <div>
              <div className="text-sm font-extrabold text-white">
                Download App
              </div>
              <div className="mt-3 flex flex-col gap-3 sm:flex-row sm:flex-wrap sm:justify-start">
                <StoreBadge
                  iconSrc={appleIcon}
                  topText="DOWNLOAD ON"
                  bottomText="App Store"
                  onClick={() => showToast("Coming Soon!")}
                />
                <StoreBadge
                  iconSrc={googleIcon}
                  topText="GET IT ON"
                  bottomText="Google Play"
                />
              </div>
            </div>
          </div>

          <div className="mt-10 flex flex-col gap-2 border-t border-white/5 pt-6 sm:flex-row sm:items-center sm:justify-between">
            <div className="text-xs text-white/45">
              © 2026 runme Nigeria. All academic rights reserved.
            </div>
            <div className="flex items-center gap-2 text-xs text-white/45">
              <span className="inline-block h-2 w-2 rounded-full bg-green-300" />
              ENYATA & INTERSWITCH BUILDATHON 2026
            </div>
          </div>
        </div>
      </div>

      <div id="support" className="sr-only" />
    </footer>
  );
}
