export type QuickAddProps = {
  content: string;
  count: number;
  addEntry: (content: string) => void;
};

export default function QuickAdd(props: QuickAddProps) {
  if (props.addEntry === undefined) {
    console.error("No addEntry defined");
  }
  return (
    <button
      className="rounded-2xl bg-blue-500 px-4 py-2 text-white"
      onClick={() => props.addEntry(props.content)}>
      {props.content}
    </button>
  );
}
