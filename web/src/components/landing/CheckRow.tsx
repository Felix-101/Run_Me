type CheckRowProps = { text: string };

export default function CheckRow(props: CheckRowProps) {
  return (
    <div className="flex items-start gap-3">
      <div className="mt-1 flex h-6 w-6 items-center justify-center rounded-full bg-green-400/10 ring-1 ring-green-400/20">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none">
          <path
            d="M20 6L9 17L4 12"
            stroke="#86efac"
            strokeWidth="2.5"
            strokeLinecap="round"
            strokeLinejoin="round"
          />
        </svg>
      </div>
      <div className="text-sm leading-relaxed text-white/70">{props.text}</div>
    </div>
  );
}
