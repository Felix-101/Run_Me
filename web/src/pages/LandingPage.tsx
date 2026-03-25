import CampusLifeSection from "../components/landing/CampusLifeSection";
import DownloadFromPocketSection from "../components/landing/DownloadFromPocketSection";
import HeroSection from "../components/landing/HeroSection";
import JoinAndFooterSection from "../components/landing/JoinAndFooterSection";
import SecuritySection from "../components/landing/SecuritySection";
import StatsStrip from "../components/landing/StatsStrip";
import StudentsLendersSection from "../components/landing/StudentsLendersSection";

export default function LandingPage() {
  return (
    <div className="min-h-screen bg-black font-sans text-white">
      <HeroSection />
      <StatsStrip />
      <CampusLifeSection />
      <StudentsLendersSection />
      <SecuritySection />
      <DownloadFromPocketSection />
      <JoinAndFooterSection />
    </div>
  );
}
