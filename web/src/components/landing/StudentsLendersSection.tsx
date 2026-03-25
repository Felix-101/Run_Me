import academicContainer from "../../../assets/image/academic_container.png";
import CheckRow from "./CheckRow";

export default function StudentsLendersSection() {
  return (
    <section className="relative overflow-hidden bg-black">
      <div className="mx-auto w-full max-w-7xl px-6 py-16">
        <div className="grid items-center gap-10 md:grid-cols-2">
          <div className="space-y-10">
            <div id="for-students" className="space-y-4">
              <div className="text-xs font-bold tracking-widest text-green-300">FOR STUDENTS</div>
              <div className="text-3xl font-extrabold text-white">Don’t let cash stop your degree.</div>
              <div className="space-y-4">
                <CheckRow text="Lower Rates than traditional micro-lenders and banks." />
                <CheckRow text="No Collateral - your student identity and grades are your security." />
                <CheckRow text="Support Community - get mentored by the lenders funding your future." />
              </div>
            </div>

            <div id="for-lenders" className="space-y-4">
              <div className="text-xs font-bold tracking-widest text-green-300">FOR LENDERS &amp; ALUMNI</div>
              <div className="text-3xl font-extrabold text-white">Empower Your Alma Mater.</div>
              <div className="space-y-4">
                <CheckRow text="Impactful Returns better than standard savings or mutual funds." />
                <CheckRow text="Help Your Department by selecting students in your field of study." />
              </div>
            </div>
          </div>

          <div className="relative">
            <div className="overflow-hidden rounded-3xl bg-white/5 ring-1 ring-white/10">
              <img
                alt="Students"
                className="h-auto w-full"
                loading="lazy"
                decoding="async"
                src={academicContainer}
              />
            </div>

            <div className="absolute bottom-6 left-6 rounded-2xl bg-green-400 px-6 py-4">
              <div className="text-4xl font-extrabold leading-none text-black">94.8%</div>
              <div className="mt-1 text-xs font-semibold text-black/80">
                Student satisfaction rating across our Nigerian campus network.
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
