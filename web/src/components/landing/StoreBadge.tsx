type StoreBadgeProps = {
  iconSrc: string;
  topText: string;
  bottomText: string;
  onClick?: () => void;
};

const shellClass =
  "flex items-center gap-3 rounded-2xl bg-black px-5 py-3 ring-1 ring-white/15";

export default function StoreBadge(props: StoreBadgeProps) {
  const inner = (
    <>
      <img alt="" className="h-8 w-8 shrink-0 object-contain" src={props.iconSrc} />
      <div className="leading-tight">
        <div className="text-[11px] font-medium text-white/70">{props.topText}</div>
        <div className="text-[13px] font-semibold text-white">{props.bottomText}</div>
      </div>
    </>
  );

  if (props.onClick) {
    return (
      <button
        type="button"
        onClick={props.onClick}
        className={`${shellClass} w-full cursor-pointer text-left transition hover:bg-white/[0.06] sm:w-auto`}
      >
        {inner}
      </button>
    );
  }

  return <div className={shellClass}>{inner}</div>;
}
