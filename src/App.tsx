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
import moment, { Moment } from "moment";
import { toast } from "sonner";
import { CirclePlus, Download, Upload } from "lucide-react";
import { ResetItems } from "./components/ResetItems";

const STORAGE_ITEM_KEY = "entries";

type SerialisedItem = {
  id: string;
  content: string;
  created: string;
};

const deserialise = (serialized: string): Item[] => {
  return JSON.parse(serialized).map((item: SerialisedItem) => {
    return {
      id: item.id,
      content: item.content,
      created: moment(item.created),
    };
  });
};

const fetchState = (): Item[] => {
  const serialized = localStorage.getItem(STORAGE_ITEM_KEY);
  return serialized === null ? [] : deserialise(serialized);
};

const persistState = (updatedItems: Item[]) => {
  const serialized = JSON.stringify(updatedItems);
  localStorage.setItem(STORAGE_ITEM_KEY, serialized);
};

function App() {
  const [items, setItems] = useState(fetchState());
  const [newText, setNewText] = useState("");
  const [importing, setImporting] = useState(false);

  const resetItems = () => {
    setItems([]);
    persistState([]);
    toast.info("Items reset");
  };

  const addItem = (content: string): void => {
    if (!content) {
      toast.error("No description added");
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
    toast.info("Item deleted");
  };

  const updateItem = (id: string, content: string, created: Moment): void => {
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
    toast("Item updated");
  };

  const importState = (state: Item[]) => {
    setItems(state);
    persistState(state);
    setImporting(false);
    toast("Imported state");
  };

  const exportState = async (): Promise<void> => {
    const entriesText = localStorage.getItem("entries") || "[]";
    const type = "text/plain";
    const blob = new Blob([entriesText], { type });
    const data = [new ClipboardItem({ [type]: blob })];
    await navigator.clipboard.write(data);
    toast("Copied items to clipboard");
  };

  if (importing) {
    return (
      <ImportDialogue
        cancelImport={() => setImporting(false)}
        importState={importState}
      />
    );
  }

  return (
    <div className="flex h-screen flex-col">
      <main className="flex w-screen flex-1 flex-col gap-4 overflow-y-auto p-4 text-lg md:text-base">
        <div className="flex items-center justify-between">
          <h1 className="text-4xl font-bold leading-tight tracking-tight md:text-2xl">
            RememberIt
          </h1>
          <div className="flex">
            <ModeToggle />
            <img
              src="icons/remembering.png"
              className="w-8 rounded-full bg-white p-1"
            ></img>
          </div>
        </div>
        <div className="flex justify-start gap-2">
          {/* Reset entries */}
          <ResetItems items={items} resetItems={resetItems} />
          {/* export state */}
          <Button variant="outline" onClick={exportState}>
            <Download />
          </Button>
          {/* import state */}
          <Button variant="outline" onClick={() => setImporting(true)}>
            <Upload />
          </Button>
        </div>

        <QuickAdds entries={items} addEntry={addItem} />

        <form
          className="flex items-center gap-2"
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
            <CirclePlus />
          </Button>
        </form>
        <EntryList items={items} deleteFn={deleteItem} updateFn={updateItem} />
      </main>
      <Footer />
    </div>
  );
}

export default App;
