import { Trash2 } from "lucide-react";
import { Button } from "./ui/button";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from "./ui/alert-dialog";
import { Item } from "@/types/item";
import { toast } from "sonner";

type ResetItemsProps = {
  items: Item[];
  resetItems: () => void;
};

export const ResetItems = (props: ResetItemsProps) => {
  const clickHandler = () => {
    if (props.items.length > 0) {
      props.resetItems();
    } else {
      toast.warning("No items found to delete");
    }
  };

  return (
    <AlertDialog>
      <AlertDialogTrigger asChild>
        <Button variant="destructive">
          <Trash2 />
        </Button>
      </AlertDialogTrigger>
      <AlertDialogContent>
        <AlertDialogHeader>
          <AlertDialogTitle className="text-2xl md:text-lg">
            Reset items?
          </AlertDialogTitle>
          <AlertDialogDescription className="md:text-md text-lg">
            This action cannot be undone. This will permanently delete all of
            your items.
          </AlertDialogDescription>
        </AlertDialogHeader>
        <AlertDialogFooter>
          <AlertDialogCancel className="md:text-md text-lg">
            Cancel
          </AlertDialogCancel>
          <AlertDialogAction
            className="md:text-md text-lg"
            onClick={clickHandler}
          >
            Reset
          </AlertDialogAction>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  );
};
