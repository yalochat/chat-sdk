# Translations

The chat ships with built-in translations for its interface strings. The active language follows the `locale` you pass in the configuration, and every built-in string is translated for each supported locale.

## Overriding text

The `texts` configuration object lets you replace individual built-in strings with your own copy.

Overriding a string opts that string out of the built-in localization. The value you pass is rendered exactly as given for every locale, and the SDK no longer translates it. This is per field: fields you do not override keep their built-in translations.

```js
const client = new YaloChatClient({
  channelId: 'your-channel',
  organizationId: 'your-org',
  channelName: 'Support',
  target: '#chat-root',
  texts: {
    inputPlaceholder: 'Type here to reach us',
  },
});
```

Available fields:

- **`inputPlaceholder`** (`string`): Placeholder shown in the message input while it is empty. Also used as the input accessible label.

## Localization is your responsibility when overriding

Because an overridden string opts out of the built-in localization, translating it for each locale becomes the host app's job.

- If your app supports a single language, pass the string in that language and you are done.
- If your app supports several languages, the host app must supply the right string for the active language. Read your app language, pick the matching copy, and pass it in `texts`. Update the value if the user switches language.

When a field is omitted, the SDK uses its own translated default, so leave a field out whenever the built-in copy is good enough.
