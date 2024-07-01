import { useState } from "react";
import { Button, FlatList, Text, TextInput, View } from "react-native";
import 'react-native-get-random-values';
import { v4 as uuidv4} from 'uuid';

type Entry = {
  content: string;
  created: Date,
  id: string,
}

export default function Index() {
  const [entries, setEntries] = useState([]);
  const [newEntry, setNewENntry] = useState("");

  function addEntry(text: string) {
    const entry: Entry = {
      content:text,
      created: new Date(),
      id: uuidv4(),
    };
    setEntries([
      ...entries,
      entry
    ]);
  }

  return (
    <View
      className="flex-1 items-center justify-center bg-white font-bold px-2"
    >
      <Text className="text-2xl">RememberIt</Text>

      <View className="flex flex-row">
        <Button title="Reset Entries" />
        <Button title="Export entries" />
        <Button title="Import entries" />
      </View>

      <View 
        className="flex flex-row space-x-5"
      >
        <Text className="">Entry: </Text>
        <TextInput
          editable
          value={newEntry}
          onChangeText={setNewENntry}
          placeholder="Enter a number"
          className="flex-1 border-black border-1 rounded-sm"></TextInput>
        <Button title="Add entry" onPress={(e) => addEntry(newEntry)}/>
      </View>

      <View className="flex-1">
        <FlatList
        data={entries}
        renderItem={({item}) => <Text>{item.content}</Text>}
        >

        </FlatList>
      </View>

    </View>
  );
}
