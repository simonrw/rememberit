import { useState } from "react";
import { Item } from "../types/item";

type ImportDialogueProps = {
  importState: (state: Item[]) => void;
  cancelImport: () => void;
};

export function ImportDialogue(props: ImportDialogueProps) {
  const [stateStr, setStateStr] = useState("");

  const updateState = () => {
    if (stateStr !== "") {
      // TODO: handle deserialisation errors
      props.importState(JSON.parse(stateStr));
    }
  };

  return (
    <div className="h-screen flex flex-col">
      <main className="dark:bg-gray-800 dark:text-white flex flex-col gap-4 p-4 w-screen flex-1 overflow-y-auto text-lg md:text-base">
        <h2>Import state</h2>
        <input
          className="text-black"
          type="textarea"
          value={stateStr}
          onChange={(e) => setStateStr(e.currentTarget.value)}
        />
        <button onClick={() => props.cancelImport()}>Cancel</button>
        <button onClick={updateState}>Import</button>
      </main>
    </div>
  );
}
