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
    <div className="flex h-screen flex-col">
      <main className="flex w-screen flex-1 flex-col gap-4 overflow-y-auto p-4 text-lg md:text-base">
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
