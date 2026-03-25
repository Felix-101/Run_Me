type StoreBadgeProps = {
  iconSrc: string;
  topText: string;
  bottomText: string;
};

export default function StoreBadge(props: StoreBadgeProps) {
  return (
    <div className="flex items-center gap-3 rounded-2xl bg-black px-5 py-3 ring-1 ring-white/15">
      <img alt="" className="h-8 w-8 shrink-0 object-contain" src={props.iconSrc} />
      <div className="leading-tight">
        <div className="text-[11px] font-medium text-white/70">{props.topText}</div>
        <div className="text-[13px] font-semibold text-white">{props.bottomText}</div>
      </div>
    </div>
  );
}
