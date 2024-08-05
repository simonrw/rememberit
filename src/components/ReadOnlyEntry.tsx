import { Item } from "../types/item";
import { TableCell } from "./ui/table";

type ReadOnlyEntryProps = {
  item: Item;
  deleteFn: (id: string) => void;
  toggleEditing: () => void;
};

export function ReadOnlyEntry(props: ReadOnlyEntryProps) {
  return (
    <TableCell
      key={props.item.id}
      className="py-2 flex gap-2 justify-between"
      onClick={() => {
        props.toggleEditing();
      }}
    >
      <div className="flex gap-2">
        <div className="text-gray-500 font-light">{props.item.created}</div>
        <div>{props.item.content}</div>
      </div>
      <div>
        <button
          onClick={() => props.deleteFn(props.item.id)}
          className="text-red-400"
        >
          <svg
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
            strokeWidth={1.5}
            stroke="currentColor"
            className="size-6"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              d="M15 12H9m12 0a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"
            />
          </svg>
        </button>
      </div>
    </TableCell>
  );
}
