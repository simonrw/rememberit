import { useState } from "react";
import { EditingEntry } from "./EditingEntry";
import { Item } from "../types/item";
import { ReadOnlyEntry } from "./ReadOnlyEntry";
import { TableRow } from "./ui/table";

export interface EntryProps {
  item: Item;
  deleteFn: (id: string) => void;
  updateFn: (id: string, content: string, created: Date) => void;
}

export function Entry(props: EntryProps) {
  const [editing, setEditing] = useState(false);
  const [newContent, setNewContent] = useState(props.item.content);
  const [newDate, setNewDate] = useState(props.item.created);

  const toggleEditing = () => {
    setEditing(!editing);
  };

  const cancelEditing = () => {
    setNewContent(props.item.content);
    setNewDate(props.item.created);
    setEditing(false);
  };

  const finishEditing = () => {
    props.updateFn(props.item.id, newContent, newDate);
    setEditing(false);
  };

  const widget = editing ? (
    <EditingEntry
      item={props.item}
      newContent={newContent}
      setNewContent={setNewContent}
      newDate={newDate}
      setNewDate={setNewDate}
      cancelEditing={cancelEditing}
      finishEditing={finishEditing}
    />
  ) : (
    <ReadOnlyEntry
      item={props.item}
      deleteFn={props.deleteFn}
      toggleEditing={toggleEditing}
    />
  );

  return <TableRow>{widget}</TableRow>;
}
