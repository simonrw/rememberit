import { Item } from "../types/item";
import { Button } from "./ui/button";
import { Input } from "./ui/input";

type EditingEntryProps = {
  item: Item;
  newContent: string,
  setNewContent: (newContent: string) => void,
  newDate: string,
  setNewDate: (newDate: string) => void,
  cancelEditing: () => void,
  finishEditing: () => void,
};

export function EditingEntry(props: EditingEntryProps) {
  return (
    <div key={props.item.id} className="py-4 px-2 space-y-2 flex flex-col gap-2 border border-sky-300 rounded-lg">
      <p className="text-sm">Edit item</p>
      <Input value={props.newDate} onChange={(e) => props.setNewDate(e.currentTarget.value)} aria-label="Date and time" type="datetime-local" />
      <Input
        type="text"
        value={props.newContent}
        onChange={(e) => {
          props.setNewContent(e.target.value);
        }}
      ></Input>
      <div className="flex justify-between">
        <Button
          variant="outline"
          onClick={props.cancelEditing}>
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
              d="M6 18 18 6M6 6l12 12"
            />
          </svg>
        </Button>
        <Button
          onClick={props.finishEditing}
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
              d="M9 12.75 11.25 15 15 9.75M21 12c0 1.268-.63 2.39-1.593 3.068a3.745 3.745 0 0 1-1.043 3.296 3.745 3.745 0 0 1-3.296 1.043A3.745 3.745 0 0 1 12 21c-1.268 0-2.39-.63-3.068-1.593a3.746 3.746 0 0 1-3.296-1.043 3.745 3.745 0 0 1-1.043-3.296A3.745 3.745 0 0 1 3 12c0-1.268.63-2.39 1.593-3.068a3.745 3.745 0 0 1 1.043-3.296 3.746 3.746 0 0 1 3.296-1.043A3.746 3.746 0 0 1 12 3c1.268 0 2.39.63 3.068 1.593a3.746 3.746 0 0 1 3.296 1.043 3.746 3.746 0 0 1 1.043 3.296A3.745 3.745 0 0 1 21 12Z"
            />
          </svg>
        </Button>
      </div>
    </div>
  );
}

