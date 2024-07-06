import { Entry, Item } from "./Entry";

export interface EntryListProps {
 items: Item[];
  deleteFn: (id: string) => void ;
}

export function EntryList(props: EntryListProps) {
  return (<div className="flex flex-col overflow-y-scroll">
    {props.items.map((item) => {
      return Entry({ item, deleteFn: props.deleteFn });
    })}
  </div>
  )
}
