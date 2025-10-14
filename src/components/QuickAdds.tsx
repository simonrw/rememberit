import { Item } from "../types/item";
import QuickAdd from "./QuickAdd";

export type QuickAddsProps = {
  entries: Item[];
  addEntry: (content: string) => void;
};

export default function QuickAdds(props: QuickAddsProps) {
  const quickItemCounts: Record<string, number> = props.entries.reduce(
    (acc: Record<string, number>, entry: Item) => {
      if (entry.content in acc) {
        return { ...acc, [entry.content]: acc[entry.content] + 1 };
      } else {
      }
      return { ...acc, [entry.content]: 1 };
    },
    {},
  );

  let quickAddItems = Object.entries(quickItemCounts).filter(([_, v]) => {
    return v >= 2;
  });
  quickAddItems.sort((a, b) => {
    if (a[1] < b[1]) {
      return 1;
    } else if (a[1] > b[1]) {
      return -1;
    } else {
      return 0;
    }
  });

  const quickAddComponents = quickAddItems.slice(0, 5).map(([name, count]) => {
    return (
      <QuickAdd
        key={`add-${name}`}
        content={name}
        count={count}
        addEntry={props.addEntry}
      />
    );
  });

  if (quickAddItems.length === 0) {
    return <></>;
  } else {
    return <div className="flex flex-row gap-2">{quickAddComponents}</div>;
  }
}
