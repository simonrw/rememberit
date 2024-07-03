type Item = {
  content: string;
  created: Date;
};

const items: Item[] = [
  {
    content: "First item",
    created: new Date(),
  },
  {
    content: "Second item",
    created: new Date(),
  },
  {
    content: "Third item",
    created: new Date(),
  },
];


function App() {
  return (
    <main className="flex flex-col gap-4 p-4 h-screen w-screen">
      <h1 className="text-2xl font-bold">RememberIt</h1>
      <div className="flex gap-2 justify-start">
        <button className="rounded-2xl bg-blue-500 px-4 py-2 text-white">Reset entries</button>
        <button className="rounded-2xl bg-blue-500 px-4 py-2 text-white">Export entries</button>
        <button className="rounded-2xl bg-blue-500 px-4 py-2 text-white">Import entries</button>
      </div>
      <div className="flex gap-2 items-center">
        <label htmlFor="entry-input">Entry</label>
        <input type="text" id="entry-input" className="flex-1 border border-black rounded-sm" autoFocus={true}></input>
        <button className="rounded-2xl bg-blue-500 px-4 py-2 text-white">Add entry</button>
      </div>
      <div className="flex flex-col overflow-y-scroll">
        {[...items, ...items, ...items, ...items].map((item) => {
          return Entry(item);
        })}
      </div>
    </main>
  );
}

function Entry(entry: Item) {
    return (
      <div className="flex flex-1 gap-2">
        <span className="text-gray-500 font-light">{entry.created.toLocaleString()}</span>
        <span>{entry.content}</span>
      </div>
    );
}

export default App;
