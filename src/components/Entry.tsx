import { useState } from "react";

export interface EntryProps {
  item: Item;
  deleteFn: (id: string) => void;
  updateFn: (id: string, content: string, created: string) => void;
}

export interface Item {
  id: string;
  content: string;
  created: string;
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
    console.log("Finished editing");
    props.updateFn(props.item.id, newContent, newDate);
    setEditing(false);
  };

  if (editing) {
    return <EditingEntry
      item={props.item}
      deleteFn={props.deleteFn}
      updateFn={props.updateFn}
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
      updateFn={props.updateFn}
      toggleEditing={toggleEditing}
    />
  }
}

type EditingEntryProps = {
  item: Item;
  deleteFn: (id: string) => void;
  updateFn: (id: string, content: string, created: string) => void;
  newContent: string,
  setNewContent: (newContent: string) => void,
  newDate: string,
  setNewDate: (newDate: string) => void,
  cancelEditing: () => void,
  finishEditing: () => void,
};

function EditingEntry(props: EditingEntryProps) {
  return (
    <div key={props.item.id} className="py-4 px-2 space-y-2 flex flex-col gap-2 border border-sky-300 rounded-lg">
      <p className="text-sm">Edit item</p>
      <input className="rounded-lg p-2 dark:text-black text-gray-500 font-light" value={props.newDate} onChange={(e) => props.setNewDate(e.currentTarget.value)} aria-label="Date and time" type="datetime-local" />
      <input
        className="rounded-lg text-black p-2"
        type="text"
        value={props.newContent}
        onChange={(e) => {
          props.setNewContent(e.target.value);
        }}
      ></input>
      <div className="flex justify-between">
        <button onClick={props.cancelEditing} className="text-red-400">
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
        </button>
        <button onClick={props.finishEditing} className="text-green-500">
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
        </button>
      </div>
    </div>
  );
}

type ReadOnlyEntryProps = {
  item: Item;
  deleteFn: (id: string) => void;
  updateFn: (id: string, content: string, created: string) => void;
  toggleEditing: () => void;
};

function ReadOnlyEntry(props: ReadOnlyEntryProps) {
  return (
    <div
      key={props.item.id}
      className="py-2 flex gap-2 justify-between"
      onClick={() => {
        props.toggleEditing()
      }}
    >
      <div className="flex gap-2">
        <div className="dark:text-gray-200 text-gray-500 font-light">
          {props.item.created.toLocaleString()}
        </div>
        <div>{props.item.content}</div>
      </div>
      <div>
        <button onClick={() => props.deleteFn(props.item.id)} className="text-red-400">
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
    </div>
  );
}
