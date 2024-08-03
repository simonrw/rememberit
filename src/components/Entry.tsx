import { useState } from "react";
import { EditingEntry } from "./EditingEntry";
import { Item } from "../types/item";
import { ReadOnlyEntry } from "./ReadOnlyEntry";

export interface EntryProps {
  item: Item;
  deleteFn: (id: string) => void;
  updateFn: (id: string, content: string, created: string) => void;
}


export function Entry(props: EntryProps) {
  const [editing, setEditing] = useState(false);
  const [newContent, setNewContent] = useState(props.item.content);
  const [newDate, setNewDate] = useState(props.item.created.toLocaleString());

  const toggleEditing = () => {
    setEditing(!editing);
  };

  const cancelEditing = () => {
    setNewContent(props.item.content);
    setNewDate(props.item.created.toLocaleString());
    setEditing(false);
  };

  const finishEditing = () => {
    props.updateFn(props.item.id, newContent, newDate);
    setEditing(false);
  };

  if (editing) {
    return <EditingEntry
      item={props.item}
      newContent={newContent}
      setNewContent={setNewContent}
      newDate={newDate}
      setNewDate={setNewDate}
      cancelEditing={cancelEditing}
      finishEditing={finishEditing}
    />;
  } else {
    return <ReadOnlyEntry
      item={props.item}
      deleteFn={props.deleteFn}
      toggleEditing={toggleEditing}
    />
  }
}


