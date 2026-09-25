# Translations

The chat ships with built-in translations for its interface strings. The language follows the device language, and every built-in string is translated for each supported language.

## Table of contents

- [Supported languages](#supported-languages)
- [Overriding text](#overriding-text)
- [Localization is your responsibility when overriding](#localization-is-your-responsibility-when-overriding)

## Supported languages

- English, used when the device language is not one of the languages below.
- Arabic, including right to left layout.
- Spanish, which also covers regional variants such as Mexican Spanish.
- Portuguese, which also covers regional variants such as Brazilian Portuguese.
- Chinese, which also covers regional variants such as Simplified Chinese.

Nothing has to be configured for this. Android picks the closest match to the device language on its own.

## Overriding text

Every built-in string is an Android string resource. Declaring a resource with the same name in your app replaces the one the SDK ships.

Add the string to your app's `res/values/strings.xml`:

```xml
<resources>
    <string name="yalo_chat_input_placeholder">Type here to reach us</string>
</resources>
```

This is per string. Strings you do not declare keep their built-in translations.

Available strings:

- **`yalo_chat_input_placeholder`**: Placeholder shown in the message input while it is empty.
- **`yalo_chat_send_button_description`**: Accessible label for the send button.
- **`yalo_chat_mic_button_description`**: Accessible label for the voice recording button, shown while there is nothing to send.
- **`yalo_chat_cancel_recording_description`**: Accessible label for the cross that throws a recording away.
- **`yalo_chat_play_voice_message_description`**: Accessible label for the play button on a voice message.
- **`yalo_chat_pause_voice_message_description`**: Accessible label for that button while the voice message is playing.
- **`yalo_chat_attachment_button_description`**: Accessible label for the plus that picks a picture to send.
- **`yalo_chat_image_message_description`**: Accessible label for a picture in the conversation.
- **`yalo_chat_back_button_description`**: Accessible label for the header back button.
- **`yalo_chat_unsupported_message`**: Text shown in place of a message the chat cannot display yet.
- **`yalo_chat_watermark`**: The "By Yalo" line under the channel name. Takes the brand name as its first format argument, so each translation decides where the name sits.

## Localization is your responsibility when overriding

An overridden string opts that string out of the built-in translations, so translating it becomes your app's job.

- If your app supports a single language, declare the string in `res/values/strings.xml` and you are done.
- If your app supports several languages, declare the string in each of your language folders, such as `res/values-es/strings.xml` and `res/values-ar/strings.xml`. A string declared only in `res/values` is used for every language.

When you do not declare a string, the SDK uses its own translated default, so leave a string alone whenever the built-in copy is good enough.
