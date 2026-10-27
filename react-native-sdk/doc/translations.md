# Translations

The chat ships with built-in translations for its interface strings. The language follows the device language, and every built-in string is translated for each supported language.

## Table of contents

- [Supported languages](#supported-languages)
- [Overriding text](#overriding-text)
- [Localization is your responsibility when overriding](#localization-is-your-responsibility-when-overriding)

## Supported languages

- English, used when the device language is not one of the languages below.
- Arabic (`ar`), including right to left layout.
- Chinese (`zh`, `zh-CN`).
- Portuguese (`pt`, `pt-BR`).
- Spanish (`es`, `es-MX`).

Nothing has to be configured for this. Android and iOS pick the closest match to the device language on their own.

## Overriding text

The `texts` field of `YaloChatClientConfig` takes a `YaloChatTexts` and replaces individual built-in strings with your own copy. It works like `texts` in the web SDK, so apps that ship both can share the copy.

```tsx
const client = new YaloChatClient({
  channelId: 'your-channel-id',
  organizationId: 'your-organization-id',
  channelName: 'Support',
  texts: { inputPlaceholder: 'Type here to reach us' },
});
```

This is per field. Fields left out keep their built-in translations.

Available fields:

- **`inputPlaceholder`** (`string`): Placeholder shown in the message input while it is empty.

## Localization is your responsibility when overriding

An overridden string is shown exactly as given for every language, so translating it becomes your app's job.

- If your app supports a single language, pass the string in that language and you are done.
- If your app supports several languages, read your app language, pick the matching copy, and pass it in `texts`. Create a new client if the person switches language, since the config is read when the chat is shown.

When a field is left out, the SDK uses its own translated default, so leave a field out whenever the built-in copy is good enough.
