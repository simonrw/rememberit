import { Entry, Item } from "./Entry";

export interface EntryListProps {
  items: Item[];
  deleteFn: (id: string) => void;
  updateFn: (id: string, content: string, created: string) => void;
}

export function EntryList(props: EntryListProps) {
  const sortedEntries = [...props.items].sort(sortEntry);
  console.log({ sortedEntries });
  return (
    <div className="flex flex-col overflow-y-auto">
      {sortedEntries.map((item) => {
        return <Entry key={item.id} item={item} deleteFn={props.deleteFn} updateFn={props.updateFn} />
      })}
    </div>
  );
}

const sortEntry = (a: Item, b: Item): number => {
  if (a.created === b.created) {
    return 0;
  } else {
    return a.created > b.created ? -1 : 1;
  }
}
