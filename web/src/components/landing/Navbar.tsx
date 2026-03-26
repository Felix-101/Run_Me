import brandIcon from "../../../assets/icons/container_icon_2.png";

export default function Navbar() {
  return (
    <header className="relative z-10 mx-auto w-full max-w-7xl px-6 pt-6">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <img
            alt="runme"
            className="h-10 w-10 shrink-0 object-contain"
            src={brandIcon}
            width={40}
            height={40}
          />
          <div>
            <div className="text-lg font-semibold text-white">runme</div>
          </div>
        </div>

        <nav className="hidden items-center gap-8 md:flex">
          <a
            className="text-sm font-medium text-white/70 hover:text-white"
            href="#for-students"
          >
            For Students
          </a>
          <a
            className="text-sm font-medium text-white/70 hover:text-white"
            href="#for-lenders"
          >
            Lenders
          </a>
          <a
            className="text-sm font-medium text-white/70 hover:text-white"
            href="#how-it-works"
          >
            How it Works
          </a>
        </nav>

        <div className="flex items-center gap-3">
          <a
            className="hidden rounded-2xl bg-green-400 px-5 py-2.5 text-sm font-semibold text-black hover:bg-green-300 md:block"
            href="#download"
          >
            Get the App
          </a>
          <a className="text-sm font-semibold text-white/80 md:hidden" href="#download">
            Get App
          </a>
        </div>
      </div>
    </header>
  );
}
