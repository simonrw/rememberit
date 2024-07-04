export type Item = {
  id: string;
  content: string;
  created: Date;
};


export function Entry(entry: Item) {
    return (
      <div key={entry.id} className="flex flex-1 gap-2">
        <span className="text-gray-500 font-light">{entry.created.toLocaleString()}</span>
        <span>{entry.content}</span>
      </div>
    );
}