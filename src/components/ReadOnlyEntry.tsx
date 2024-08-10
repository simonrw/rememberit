import { formatDate } from "@/date";
import { Item } from "../types/item";
import { TableCell } from "./ui/table";
import { DeleteEntry } from "./DeleteEntry";

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
    >
      <div
        className="flex cursor-pointer gap-2 text-lg md:text-sm"
        onClick={() => {
          props.toggleEditing();
        }}
      >
        <div className="font-light text-gray-500">
          {formatDate(props.item.created)}
        </div>
        <div>{props.item.content}</div>
      </div>
      <div>
        <DeleteEntry item={props.item} deleteFn={props.deleteFn} />
      </div>
    </TableCell>
  );
}
