import { Link } from "react-router-dom";
import appleIcon from "../../assets/icons/apple_icon_svg.svg";
import googleIcon from "../../assets/icons/google_icon_svg.svg";
import StoreBadge from "../components/landing/StoreBadge";

export default function InstructorsPage() {
  return (
    <div className="min-h-screen bg-black font-sans text-white">
      <div className="mx-auto max-w-2xl px-6 pb-24 pt-10">
        <Link
          to="/"
          className="inline-flex text-sm font-medium text-green-400 hover:text-green-300"
        >
          ← Back to runme
        </Link>

        <div className="mt-8 inline-flex rounded-full bg-amber-400/15 px-4 py-2 text-[11px] font-semibold tracking-wide text-amber-300 ring-1 ring-amber-400/30">
          Enyata × Interswitch Buildathon 2026
        </div>

        <h1 className="mt-6 font-heading text-3xl font-bold tracking-tight text-white md:text-4xl">
          Instructor setup
        </h1>
        <p className="mt-3 text-base leading-relaxed text-white/65">
          Use this page to install the mobile app and access the lending admin console for demos and
          judging.
        </p>

        <section className="mt-10 rounded-2xl border border-white/10 bg-white/[0.04] p-6">
          <h2 className="text-sm font-semibold uppercase tracking-wider text-green-300">
            1. Download the app
          </h2>
          <p className="mt-3 text-sm leading-relaxed text-white/70">
            Install the runme mobile app from the store links below when they are live, or use the APK /
            TestFlight build supplied by the buildathon team. You can also scroll to the download section
            on the{" "}
            <Link to="/#download" className="font-semibold text-green-400 hover:text-green-300">
              home page
            </Link>
            .
          </p>
          <div className="mt-6 flex flex-col gap-3 sm:flex-row">
            <StoreBadge iconSrc={appleIcon} topText="DOWNLOAD ON" bottomText="App Store" />
            <StoreBadge iconSrc={googleIcon} topText="GET IT ON" bottomText="Google Play" />
          </div>
        </section>

        <section className="mt-6 rounded-2xl border border-white/10 bg-white/[0.04] p-6">
          <h2 className="text-sm font-semibold uppercase tracking-wider text-green-300">
            2. Admin dashboard access
          </h2>
          <p className="mt-3 text-sm leading-relaxed text-white/70">
            The <strong className="text-white">RunMe Lending Admin</strong> is a separate web app (in the
            repo under <code className="rounded bg-black/40 px-1.5 py-0.5 text-xs text-green-200/90">admin/</code>
            ). Deploy it against your API or use the URL shared by organizers.
          </p>
          <ul className="mt-4 list-disc space-y-2 pl-5 text-sm text-white/70">
            <li>
              Sign in with an account that has the <strong className="text-white">admin</strong> role.
            </li>
            <li>
              For API demos, the server can create a bootstrap admin when{" "}
              <code className="rounded bg-black/40 px-1.5 py-0.5 text-xs">ADMIN_EMAIL</code> and{" "}
              <code className="rounded bg-black/40 px-1.5 py-0.5 text-xs">ADMIN_PASSWORD</code> are set
              (see <code className="rounded bg-black/40 px-1.5 py-0.5 text-xs">docs/SERVER_ENV.md</code> in
              the project).
            </li>
            <li>
              If you only need the public student web experience, use{" "}
              <Link to="/login" className="font-semibold text-green-400 hover:text-green-300">
                /login
              </Link>{" "}
              on this site (not the admin console).
            </li>
          </ul>
        </section>

        <p className="mt-8 text-center text-xs text-white/45">
          Questions? Use the official Enyata / Interswitch instructor channel for credentials and
          deployment URLs.
        </p>
      </div>
    </div>
  );
}
