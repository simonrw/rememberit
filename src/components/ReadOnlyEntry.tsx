import { formatDate } from "@/date";
import { Item } from "../types/item";
import { TableCell } from "./ui/table";
import { Button } from "./ui/button";
import { Delete } from "lucide-react";

type ReadOnlyEntryProps = {
  item: Item;
  deleteFn: (id: string) => void;
  toggleEditing: () => void;
};

export function ReadOnlyEntry(props: ReadOnlyEntryProps) {
  return (
    <TableCell
      key={props.item.id}
      className="flex items-center justify-between gap-2 py-2"
      onClick={() => {
        props.toggleEditing();
      }}
    >
      <div className="flex gap-2 text-lg md:text-sm">
        <div className="font-light text-gray-500">
          {formatDate(props.item.created)}
        </div>
        <div>{props.item.content}</div>
      </div>
      <div>
        <Button
          onClick={() => props.deleteFn(props.item.id)}
          className="text-red-400"
          variant="ghost"
        >
          <Delete />
        </Button>
      </div>
    </TableCell>
  );
}
