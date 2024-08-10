import { formatDate } from "@/date";
import { Item } from "../types/item";
import { Button } from "./ui/button";
import { Input } from "./ui/input";
import { TableCell } from "./ui/table";
import moment, { Moment } from "moment";
import { CircleCheck, CircleX } from "lucide-react";

type EditingEntryProps = {
  item: Item;
  newContent: string;
  setNewContent: (newContent: string) => void;
  newDate: Moment;
  setNewDate: (newDate: Moment) => void;
  cancelEditing: () => void;
  finishEditing: () => void;
};

export function EditingEntry(props: EditingEntryProps) {
  const dateForInput = props.newDate.toISOString().slice(0, -1);
  return (
    <TableCell>
      <div
        key={props.item.id}
        className="flex flex-col gap-2 space-y-2 rounded-lg border border-sky-300 px-2 py-4"
      >
        <p className="text-lg md:text-sm">Edit item</p>
        <Input
          value={dateForInput}
          onChange={(e) => props.setNewDate(moment(e.currentTarget.value))}
          aria-label="Date and time"
          type="datetime-local"
        />
        <Input
          type="text"
          value={props.newContent}
          onChange={(e) => {
            props.setNewContent(e.target.value);
          }}
        ></Input>
        <div className="flex justify-between">
          <Button variant="outline" onClick={props.cancelEditing}>
            <CircleX />
          </Button>
          <Button onClick={props.finishEditing}>
            <CircleCheck />
          </Button>
        </div>
      </div>
    </TableCell>
  );
}
