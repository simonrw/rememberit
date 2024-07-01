import { Text } from 'react-native';
import { Entry as EntryType } from '@/types/entry';

interface EntryProps {
    entry: EntryType;
}

export default function Entry({entry}: EntryProps) {
    return <Text>{entry.content}</Text>
}