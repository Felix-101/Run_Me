export default function StatsStrip() {
  return (
    <section className="bg-black">
      <div className="mx-auto w-full max-w-7xl px-6 py-10">
        <div className="grid gap-8 sm:grid-cols-2 lg:grid-cols-4">
          <div className="text-center">
            <div className="text-4xl font-extrabold text-white">1.2B+</div>
            <div className="mt-2 text-sm font-medium text-white/60">DISBURSED</div>
          </div>
          <div className="text-center">
            <div className="text-4xl font-extrabold text-green-300">45k+</div>
            <div className="mt-2 text-sm font-medium text-white/60">STUDENTS HELPED</div>
          </div>
          <div className="text-center">
            <div className="text-4xl font-extrabold text-white">12%</div>
            <div className="mt-2 text-sm font-medium text-white/60">AVG. ANNUAL YIELD</div>
          </div>
          <div className="text-center">
            <div className="text-4xl font-extrabold text-green-300">99.1%</div>
            <div className="mt-2 text-sm font-medium text-white/60">SUCCESS RATE</div>
          </div>
        </div>
      </div>
    </section>
  );
}
