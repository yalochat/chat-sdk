// Copyright (c) Yalochat, Inc. All rights reserved.
import { useState } from 'react';
import { Button, StyleSheet, Text, View } from 'react-native';
import { Chat, YaloChatClient } from 'yalo-chat-react-native-sdk';

const client = new YaloChatClient({
  // Fill up with your values
  channelId: 'your-channel-id',
  organizationId: 'your-organization-id',
  channelName: 'Yalo',
});

/** A host app with nothing in it but a button that opens the chat. */
export default function App() {
  const [chatIsOpen, setChatIsOpen] = useState(false);

  if (chatIsOpen) {
    return (
      <Chat
        client={client}
        avatar={{ uri: 'https://github.com/yalochat.png' }}
        onBack={() => setChatIsOpen(false)}
      />
    );
  }

  return (
    <View style={styles.page}>
      <Text>Example app</Text>
      <Button title="Open chat" onPress={() => setChatIsOpen(true)} />
    </View>
  );
}

const styles = StyleSheet.create({
  page: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    gap: 16,
  },
});
