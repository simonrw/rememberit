import { Badge } from "./ui/badge";

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
    <Badge
      variant="secondary"
      className="cursor-pointer"
      onClick={() => props.addEntry(props.content)}
    >
      {props.content}
    </Badge>
  );
}
