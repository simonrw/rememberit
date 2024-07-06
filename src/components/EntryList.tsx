import { Entry, Item } from "./Entry";

export function EntryList(props: { items: Item[] }) {
  return (<div className="flex flex-col overflow-y-scroll">
    {props.items.map((item) => {
      return Entry(item);
    })}
  </div>
  )
}
