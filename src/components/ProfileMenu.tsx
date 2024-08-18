import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger } from "./ui/dropdown-menu";

type ProfileMenuProps = {
};

export const ProfileMenu = (props: ProfileMenuProps) => {
  return (
    <DropdownMenu>
      <DropdownMenuTrigger>
        <img
          src="icons/remembering.png"
          className="w-8 rounded-full bg-white p-1"
        ></img>
      </DropdownMenuTrigger>
      <DropdownMenuContent>
        <DropdownMenuItem>Settings</DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  );
};
