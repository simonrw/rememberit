import { v4 as uuidv4 } from 'uuid';
import { useState } from "react";
import { Entry, Item } from "./Entry";

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

  return (
    <main className="flex flex-col gap-4 p-4 h-screen w-screen">
      <h1 className="text-2xl font-bold">RememberIt</h1>
      <div className="flex gap-2 justify-start">
        <button
          className="rounded-2xl bg-blue-500 px-4 py-2 text-white"
          onClick={() => {
            setItems([]);
            persistState([]);
          }}
        >
          Reset entries
        </button>
        <button className="rounded-2xl bg-blue-500 px-4 py-2 text-white">
          Export entries
        </button>
        <button className="rounded-2xl bg-blue-500 px-4 py-2 text-white">
          Import entries
        </button>
      </div>
      <div className="flex gap-2 items-center">
        <label htmlFor="entry-input">Entry</label>
        <input
          type="text"
          id="entry-input"
          value={newText}
          className="flex-1 border border-black rounded-sm"
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
          Add entry
        </button>
      </div>
      <div className="flex flex-col overflow-y-scroll">
        {items.map((item) => {
          return Entry(item);
        })}
      </div>
    </main>
  );
}

function App() {
  return <Content />;
}

export default App;
