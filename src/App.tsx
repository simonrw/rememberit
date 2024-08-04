import { v4 as uuidv4 } from "uuid";
import { useState } from "react";
import { EntryList } from "./components/EntryList";
import QuickAdds from "./components/QuickAdds";
import { newDate } from "./date";
import { Footer } from "./components/Footer";
import { Item } from "./types/item";
import { ImportDialogue } from "./components/ImportDialogue";
import { ModeToggle } from "./components/mode-toggle";
import { Button } from "./components/ui/button";
import { Input } from "./components/ui/input";
import { useToast } from "./components/ui/use-toast";

const STORAGE_ITEM_KEY = "entries";

const fetchState = (): Item[] => {
  const serialized = localStorage.getItem(STORAGE_ITEM_KEY);
  return serialized === null ? [] : JSON.parse(serialized);
};

function Content() {
  const [items, setItems] = useState(fetchState());
  const [newText, setNewText] = useState("");
  const [importing, setImporting] = useState(false);

  const { toast } = useToast()


  const persistState = (updatedItems: Item[]) => {
    const serialized = JSON.stringify(updatedItems);
    localStorage.setItem(STORAGE_ITEM_KEY, serialized);
  };

  const resetItems = () => {
    setItems([]);
    persistState([]);
    toast({
      description: "Items reset",
    });
  };

  const addItem = (content: string): void => {
    if (!content) {
      toast({ description: "No description added", variant: "destructive" });
      return;
    }

    const newItem: Item = { content, id: uuidv4(), created: newDate() };
    setItems((oldItems) => {
      const newItems = [...oldItems, newItem];
      persistState(newItems);
      return newItems;
    });
  };

  const deleteItem = (id: string): void => {
    setItems((oldItems) => {
      const newItems = oldItems.filter((i) => i.id !== id);
      persistState(newItems);
      return newItems;
    });
    toast({ variant: "destructive", description: "Item deleted" });
  };

  const updateItem = (id: string, content: string, created: string): void => {
    setItems((oldItems) => {
      const newItems = oldItems.map((item) => {
        if (item.id === id) {
          return { id, content, created };
        } else {
          return item;
        }
      });
      persistState(newItems);
      return newItems;
    });
    toast({ description: "Item updated" });
  };

  const importState = (state: Item[]) => {
    setItems(state);
    persistState(state);
    setImporting(false);
    toast({ description: "Imported state" });
  };

  const exportState = async (): Promise<void> => {
    const entriesText = localStorage.getItem("entries") || "[]";
    const type = "text/plain";
    const blob = new Blob([entriesText], { type });
    const data = [new ClipboardItem({ [type]: blob })];
    await navigator.clipboard.write(data);
    toast({ description: "Copied items to clipboard" });
  };

  if (importing) {
    return <ImportDialogue
      cancelImport={() => setImporting(false)}
      importState={importState}
    />
  }

  return (
    <div className="h-screen flex flex-col">
      <main className="flex flex-col gap-4 p-4 w-screen flex-1 overflow-y-auto text-lg md:text-base">
        <div className="flex items-center justify-between">
          <h1 className="text-4xl md:text-2xl font-bold leading-tight tracking-tight">RememberIt</h1>
          <div className="flex">
            <ModeToggle />
            <img src="icons/remembering.png" className="w-8 bg-white rounded-full p-1"></img>
          </div>
        </div>
        <div className="flex gap-2 justify-start">
          {/* Reset entries */}
          <Button variant="destructive"
            onClick={resetItems}
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
          </Button>
          {/* export state */}
          <Button
            variant="outline"
            onClick={exportState}
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
                d="M19.5 13.5 12 21m0 0-7.5-7.5M12 21V3"
              />
            </svg>
          </Button>
          {/* import state */}
          <Button
            variant="outline"
            onClick={() => setImporting(true)}
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
                d="M4.5 10.5 12 3m0 0 7.5 7.5M12 3v18"
              />
            </svg>
          </Button>
        </div>

        <QuickAdds entries={items} addEntry={addItem} />

        <form className="flex gap-2 items-center"
          onSubmit={(e) => {
            e.preventDefault();
            addItem(newText);
            setNewText("");
          }}
        >
          <Input
            placeholder="What would you like to remember?"
            type="text"
            id="entry-input"
            value={newText}
            autoFocus={true}
            onChange={(e) => {
              setNewText(e.target.value);
            }}
          ></Input>
          <Button>
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
          </Button>
        </form>
        <EntryList items={items} deleteFn={deleteItem} updateFn={updateItem} />
      </main>
      <Footer />
    </div>
  );
}

function App() {
  return <Content />;
}

export default App;
