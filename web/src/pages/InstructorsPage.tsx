import { useState } from "react";
import { Link } from "react-router-dom";
import appleIcon from "../../assets/icons/apple_icon_svg.svg";
import googleIcon from "../../assets/icons/google_icon_svg.svg";
import StoreBadge from "../components/landing/StoreBadge";

const APK_DRIVE_URL =
  "https://drive.google.com/file/d/1N4oqkOfnoRrl9XherUi2kLxCeek0SPF5/view?usp=sharing";
const ADMIN_APP_URL = "https://runmeadmin.netlify.app/";
const CONTACT_EMAIL = "jonesinim@gmail.com";

async function copyToClipboard(text: string): Promise<boolean> {
  try {
    await navigator.clipboard.writeText(text);
    return true;
  } catch {
    try {
      const ta = document.createElement("textarea");
      ta.value = text;
      ta.style.position = "fixed";
      ta.style.left = "-9999px";
      document.body.appendChild(ta);
      ta.focus();
      ta.select();
      const ok = document.execCommand("copy");
      document.body.removeChild(ta);
      return ok;
    } catch {
      return false;
    }
  }
}

function AdminAccessRequestForm() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [formError, setFormError] = useState<string | null>(null);

  function sendRequest() {
    setFormError(null);
    const trimmedEmail = email.trim();
    if (!trimmedEmail) {
      setFormError("Enter the email you want to use for admin sign-in.");
      return;
    }
    if (!password) {
      setFormError("Enter the password you want to use for admin sign-in.");
      return;
    }

    const subject = encodeURIComponent("RunMe admin dashboard — access request");
    const body = encodeURIComponent(
      `Please add the following credentials for RunMe Lending Admin access.\n\n` +
        `Requested login email: ${trimmedEmail}\n` +
        `Requested password: ${password}\n\n` +
        `(Sent from the RunMe instructor setup page.)`
    );
    window.location.href = `mailto:${CONTACT_EMAIL}?subject=${subject}&body=${body}`;
  }

  return (
    <div className="mt-6 rounded-xl border border-white/10 bg-black/30 p-4">
      <p className="text-xs font-semibold uppercase tracking-wider text-green-300/90">
        Request admin credentials
      </p>
      <p className="mt-2 text-xs text-white/55">
        Fill in the email and password you want for the dashboard. The button opens your mail app with a
        pre-filled message to {CONTACT_EMAIL} — send it to complete the request.
      </p>
      <label className="mt-4 block">
        <span className="mb-1 block text-[11px] font-semibold uppercase text-white/50">Email</span>
        <input
          type="email"
          autoComplete="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          className="w-full rounded-xl border border-white/15 bg-black/40 px-3 py-2.5 text-sm text-white placeholder:text-white/35 focus:border-green-400/50 focus:outline-none focus:ring-1 focus:ring-green-400/30"
          placeholder="you@school.edu"
        />
      </label>
      <label className="mt-3 block">
        <span className="mb-1 block text-[11px] font-semibold uppercase text-white/50">Password</span>
        <input
          type="password"
          autoComplete="new-password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          className="w-full rounded-xl border border-white/15 bg-black/40 px-3 py-2.5 text-sm text-white placeholder:text-white/35 focus:border-green-400/50 focus:outline-none focus:ring-1 focus:ring-green-400/30"
          placeholder="Choose a strong password"
        />
      </label>
      {formError ? <p className="mt-2 text-xs text-amber-300">{formError}</p> : null}
      <button
        type="button"
        onClick={sendRequest}
        className="mt-4 w-full rounded-xl bg-green-400 py-2.5 text-sm font-semibold text-black hover:bg-green-300 sm:w-auto sm:px-6"
      >
        Send request email
      </button>
    </div>
  );
}

export default function InstructorsPage() {
  const [apkCopied, setApkCopied] = useState(false);

  async function copyApkUrl() {
    const ok = await copyToClipboard(APK_DRIVE_URL);
    if (ok) {
      setApkCopied(true);
      window.setTimeout(() => setApkCopied(false), 2000);
    }
  }

  return (
    <div className="min-h-screen bg-black font-sans text-white">
      <div className="mx-auto max-w-2xl px-6 pb-24 pt-10">
        <div className="flex flex-col gap-5 sm:flex-row sm:flex-wrap sm:items-center sm:justify-between sm:gap-8">
          <Link
            to="/"
            className="inline-flex w-fit shrink-0 text-sm font-medium text-green-400 hover:text-green-300"
          >
            ← Back to runme
          </Link>
          <div className="inline-flex w-fit rounded-full bg-amber-400/15 px-4 py-2 text-[11px] font-semibold tracking-wide text-amber-300 ring-1 ring-amber-400/30">
            Enyata × Interswitch Buildathon 2026
          </div>
        </div>

        <h1 className="mt-8 font-heading text-3xl font-bold tracking-tight text-white md:text-4xl">
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
            The runme mobile app is built with{" "}
            <strong className="text-white">Flutter</strong>. For the buildathon, install the Android APK
            from Google Drive (link below). App Store / Google Play listings will follow when published.
          </p>
          <p className="mt-4">
            <a
              href={APK_DRIVE_URL}
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex rounded-xl bg-green-400 px-4 py-2.5 text-sm font-semibold text-black hover:bg-green-300"
            >
              Download APK (Google Drive)
            </a>
          </p>
          <div className="mt-3 flex flex-col gap-2 sm:flex-row sm:items-start sm:gap-3">
            <p className="min-w-0 flex-1 text-xs leading-relaxed text-white/50">
              <span className="text-white/45">Direct link:</span>{" "}
              <a
                href={APK_DRIVE_URL}
                target="_blank"
                rel="noopener noreferrer"
                className="break-all text-green-400/90 hover:text-green-300"
              >
                {APK_DRIVE_URL}
              </a>
            </p>
            <button
              type="button"
              onClick={() => void copyApkUrl()}
              className="shrink-0 rounded-xl border border-white/20 bg-white/5 px-3 py-2 text-xs font-semibold text-white/90 hover:border-green-400/40 hover:bg-white/10"
            >
              {apkCopied ? "Copied!" : "Copy link"}
            </button>
          </div>
          <p className="mt-6 text-xs font-medium uppercase tracking-wider text-white/45">
            Store badges (when live)
          </p>
          <div className="mt-3 flex flex-col gap-3 sm:flex-row">
            <StoreBadge iconSrc={appleIcon} topText="DOWNLOAD ON" bottomText="App Store" />
            <StoreBadge iconSrc={googleIcon} topText="GET IT ON" bottomText="Google Play" />
          </div>
          <p className="mt-4 text-sm text-white/55">
            You can also open the download section on the{" "}
            <Link to="/#download" className="font-semibold text-green-400 hover:text-green-300">
              home page
            </Link>
            .
          </p>
        </section>

        <section className="mt-6 rounded-2xl border border-white/10 bg-white/[0.04] p-6">
          <h2 className="text-sm font-semibold uppercase tracking-wider text-green-300">
            2. Admin dashboard access
          </h2>
          <p className="mt-3 text-sm leading-relaxed text-white/70">
            The <strong className="text-white">RunMe Lending Admin</strong> is on Netlify at{" "}
            <a
              href={ADMIN_APP_URL}
              target="_blank"
              rel="noopener noreferrer"
              className="break-all font-semibold text-green-400 hover:text-green-300"
            >
              {ADMIN_APP_URL}
            </a>
            . Use <strong className="text-white">Sign in</strong> on that site, or open the{" "}
            <a
              href={`${ADMIN_APP_URL}login`}
              target="_blank"
              rel="noopener noreferrer"
              className="font-semibold text-green-400 hover:text-green-300"
            >
              login page
            </a>{" "}
            directly (requires a current admin deploy that includes Netlify SPA redirects).
          </p>
          <p className="mt-3 text-sm leading-relaxed text-white/70">
            Sign-in uses an <strong className="text-white">admin</strong> account on the API. After your
            credentials are added, use them on the admin login screen.
          </p>

          <AdminAccessRequestForm />

          <ul className="mt-6 list-disc space-y-2 pl-5 text-sm text-white/60">
            <li>
              Source for the admin UI lives in the repo under{" "}
              <code className="rounded bg-black/40 px-1.5 py-0.5 text-xs text-green-200/90">admin/</code> if
              you need to run or extend it locally.
            </li>
            <li>
              For the public student web experience on this marketing site, use{" "}
              <Link to="/login" className="font-semibold text-green-400 hover:text-green-300">
                /login
              </Link>{" "}
              (not the Netlify admin URL).
            </li>
          </ul>
        </section>

        <p className="mt-8 text-center text-xs text-white/45">
          Buildathon questions? Use the official Enyata / Interswitch instructor channels; for admin
          accounts, contact {CONTACT_EMAIL}.
        </p>
      </div>
    </div>
  );
}
