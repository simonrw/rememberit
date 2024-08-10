import { Delete } from "lucide-react";
import { Button } from "./ui/button";
import { Item } from "@/types/item";
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

type DeleteEntryProps = {
  item: Item;
  deleteFn: (id: string) => void;
};

export const DeleteEntry = (props: DeleteEntryProps) => {
  return (
    <AlertDialog>
      <AlertDialogTrigger asChild>
        <Button className="text-red-400" variant="ghost">
          <Delete />
        </Button>
      </AlertDialogTrigger>
      <AlertDialogContent>
        <AlertDialogHeader>
          <AlertDialogTitle className="text-2xl md:text-lg">
            Delete item?
          </AlertDialogTitle>
          <AlertDialogDescription className="md:text-md text-lg">
            This action cannot be undone. This will permanently delete your
            item.
          </AlertDialogDescription>
        </AlertDialogHeader>
        <AlertDialogFooter>
          <AlertDialogCancel className="md:text-md text-lg">
            Cancel
          </AlertDialogCancel>
          <AlertDialogAction
            className="md:text-md text-lg"
            onClick={() => props.deleteFn(props.item.id)}
          >
            Delete
          </AlertDialogAction>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  );
};
