import { Footer } from "@/components/Footer";
import { ModeToggle } from "@/components/mode-toggle";
import { ProfileMenu } from "@/components/ProfileMenu";
import { Outlet } from "react-router-dom";

const Root = (props) => {
  return (
    <div className="flex h-screen flex-col">
      <main className="flex w-screen flex-1 flex-col gap-4 overflow-y-auto p-4 text-lg md:text-base">
        <div className="flex items-center justify-between">
          <h1 className="text-4xl font-bold leading-tight tracking-tight md:text-2xl">
            RememberIt
          </h1>
          <div className="flex">
            <ModeToggle />
            <ProfileMenu />
          </div>
        </div>
        <Outlet />
      </main>
      <Footer />
    </div>
  );
};

export default Root;
