import { useState } from "react";

export interface EntryProps {
  item: Item;
  deleteFn: (id: string) => void;
  updateFn: (id: string, content: string, created: Date) => void;
}

export interface Item {
  id: string;
  content: string;
  created: Date;
}

export function Entry(props: EntryProps) {
  const [editing, setEditing] = useState(false);
  const [newContent, setNewContent] = useState(props.item.content);

  const updateContent = (e: React.ChangeEvent<HTMLInputElement>) => {
    setNewContent(e.currentTarget.value);
    setEditing(false);
    props.updateFn(props.item.id, e.currentTarget.value, props.item.created);
  };

  if (editing) {
    return (
      <div key={props.item.id} className="flex flex-1 gap-2">
        <span className="flex flex-1 gap-2">
          <span className="dark:text-gray-200 text-gray-500 font-light">
            {props.item.created.toLocaleString()}
          </span>
          <span>
            <input
              className="text-black"
              type="text"
              value={newContent}
              onChange={(e) => {
                setNewContent(e.target.value);
              }}
              onBlur={updateContent}
            ></input>
          </span>
        </span>
      </div>
    );
  } else {
    return (
      <div key={props.item.id} className="flex flex-1 gap-2">
        <span className="flex flex-1 gap-2">
          <span className="dark:text-gray-200 text-gray-500 font-light">
            {props.item.created.toLocaleString()}
          </span>
          <span
            onClick={() => {
              setEditing(!editing);
            }}
          >
            {props.item.content}
          </span>
        </span>
        <span>
          <button onClick={() => props.deleteFn(props.item.id)}>
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
        </span>
      </div>
    );
  }
}
