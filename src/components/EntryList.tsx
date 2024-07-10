import { Entry, Item } from "./Entry";

export interface EntryListProps {
  items: Item[];
  deleteFn: (id: string) => void;
  updateFn: (id: string, content: string, created: string) => void;
}

export function EntryList(props: EntryListProps) {
  return (
    <div className="flex flex-col overflow-y-scroll">
      {props.items.map((item) => {
        return <Entry key={item.id} item={item} deleteFn={props.deleteFn} updateFn={props.updateFn} />
      })}
    </div>
  );
}
