import { v4 as uuidv4 } from "uuid";
import { useState } from "react";
import { Item } from "./components/Entry";
import { EntryList } from "./components/EntryList";

const STORAGE_ITEM_KEY = "entries";

const fetchState = (): Item[] => {
  const serialized = localStorage.getItem(STORAGE_ITEM_KEY);
  return serialized === null ? [] : JSON.parse(serialized);
};

function Content() {
  const [items, setItems] = useState(fetchState());
  const [newText, setNewText] = useState("");

  const persistState = (updatedItems: Item[]) => {
    const serialized = JSON.stringify(updatedItems);
    localStorage.setItem(STORAGE_ITEM_KEY, serialized);
  };

  const resetItems = () => {
    setItems([]);
    persistState([]);
  };

  const deleteItem = (id: string) => {
    const newItems = items.filter((i) => i.id !== id);
    setItems(newItems);
    localStorage.setItem(STORAGE_ITEM_KEY, JSON.stringify(newItems));
  };

  const exportState = async () => {
    const entriesText = localStorage.getItem("entries") || "[]";
    const type = "text/plain";
    const blob = new Blob([entriesText], { type });
    const data = [new ClipboardItem({ [type]: blob })];
    await navigator.clipboard.write(data);
  };

  return (
    <main className="dark:bg-gray-800 dark:text-white flex flex-col gap-4 p-4 h-screen w-screen">
      <h1 className="text-2xl font-bold">RememberIt</h1>
      <div className="flex gap-2 justify-start">
        <button
          className="rounded-2xl bg-blue-500 px-4 py-2 text-white"
          onClick={() => {
            setItems([]);
            persistState([]);
          }}
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
              d="m14.74 9-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 0 1-2.244 2.077H8.084a2.25 2.25 0 0 1-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 0 0-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 0 1 3.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 0 0-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 0 0-7.5 0"
            />
          </svg>

          {/* Reset entries */}
        </button>
        <button className="rounded-2xl bg-blue-500 px-4 py-2 text-white">
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
              d="M19.5 13.5 12 21m0 0-7.5-7.5M12 21V3"
            />
          </svg>
        </button>
        <button className="rounded-2xl bg-blue-500 px-4 py-2 text-white">
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
              d="M4.5 10.5 12 3m0 0 7.5 7.5M12 3v18"
            />
          </svg>
        </button>
      </div>
      <form className="flex gap-2 items-center">
        <label htmlFor="entry-input">Entry</label>
        <input
          type="text"
          id="entry-input"
          value={newText}
          className="flex-1 border border-black rounded-sm dark:text-black"
          autoFocus={true}
          onChange={(e) => {
            setNewText(e.target.value);
          }}
        ></input>
        <button
          className="rounded-2xl bg-blue-500 px-4 py-2 text-white"
          onClick={() => {
            if (newText === "") {
              return;
            }
            const newItem = {
              id: uuidv4(),
              content: newText,
              created: new Date(),
            };
            const newItems = [...items, newItem];
            setItems(newItems);
            setNewText("");
            persistState(newItems);
          }}
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
              d="M12 9v6m3-3H9m12 0a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"
            />
          </svg>
        </button>
      </form>
      <EntryList items={items} deleteFn={deleteItem}/>
    </main>
  );
}

function App() {
  return <Content />;
}

export default App;
