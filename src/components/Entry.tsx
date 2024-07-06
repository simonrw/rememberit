export interface EntryProps {
  item: Item;
  deleteFn: (id: string) => void;
}

export interface Item {
  id: string;
  content: string;
  created: Date;
}

export function Entry({ item: entry, deleteFn }: EntryProps) {
  return (
    <div key={entry.id} className="flex flex-1 gap-2">
      <span className="flex flex-1 gap-2">
        <span className="dark:text-gray-200 text-gray-500 font-light">
          {entry.created.toLocaleString()}
        </span>
        <span>{entry.content}</span>
      </span>
      <span>
        <button onClick={() => deleteFn(entry.id)}>
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
