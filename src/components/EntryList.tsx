import { Item } from "../types/item";
import { Entry } from "./Entry";
import { ScrollArea } from "./ui/scroll-area";

export interface EntryListProps {
  items: Item[];
  deleteFn: (id: string) => void;
  updateFn: (id: string, content: string, created: string) => void;
}

export function EntryList(props: EntryListProps) {
  const sortedEntries = [...props.items].sort(sortEntry);
  return (
    <ScrollArea>
      <div className="flex flex-col">
        {sortedEntries.map((item) => {
          return <Entry key={item.id} item={item} deleteFn={props.deleteFn} updateFn={props.updateFn} />
        })}
      </div>
    </ScrollArea>
  );
}

const sortEntry = (a: Item, b: Item): number => {
  if (a.created === b.created) {
    return 0;
  } else {
    return a.created > b.created ? -1 : 1;
  }
}
