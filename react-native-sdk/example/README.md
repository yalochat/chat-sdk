# Example app

A host app with a button that opens the chat. It builds against the android-sdk and ios-sdk in this repository, not the released ones.

Fill in your channel details in `src/App.tsx` first.

Use the Node version in `react-native-sdk/.nvmrc` (`nvm use`). Older versions fail to load `metro.config.js` with `require() of ES Module ... not supported`.

## Android

1. Publish the local android-sdk once, and again whenever it changes, including after pulling. Otherwise the build fails with `Unresolved reference` errors in `react-native-sdk/android`, or runs old SDK code:

   ```sh
   cd ../../android-sdk
   ./gradlew :sdk:publishToMavenLocal -PVERSION_NAME=0.0.0-local
   ```

2. From `react-native-sdk/`:

   ```sh
   npm install
   npm run example android
   ```

## iOS

From `react-native-sdk/`:

```sh
npm install
cd example/ios && bundle install && bundle exec pod install && cd ../..
npm run example ios
```

The Podfile points the pod at the ios-sdk in this repository through `YALO_CHAT_IOS_SDK_PATH`.
