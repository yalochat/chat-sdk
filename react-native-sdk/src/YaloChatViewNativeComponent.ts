// Copyright (c) Yalochat, Inc. All rights reserved.
import type * as React from 'react';
import {
  codegenNativeCommands,
  codegenNativeComponent,
  type HostComponent,
  type ViewProps,
} from 'react-native';
// React Native 0.76 codegen only knows these types by name, not through the
// CodegenTypes namespace.
import type {
  DirectEventHandler,
  WithDefault,
} from 'react-native/Libraries/Types/CodegenTypes';

export type CommandEvent = Readonly<{
  requestId: string;
  command: string;
  payload: string;
}>;

interface NativeProps extends ViewProps {
  config: string;
  theme: string;
  showsBackButton?: WithDefault<boolean, false>;
  commands?: ReadonlyArray<string>;
  onBack?: DirectEventHandler<Readonly<{}>>;
  onCommand?: DirectEventHandler<CommandEvent>;
}

interface NativeCommands {
  resolveCommand: (
    viewRef: React.ElementRef<HostComponent<NativeProps>>,
    requestId: string,
    succeeded: boolean,
    payload: string
  ) => void;
}

export const Commands: NativeCommands = codegenNativeCommands<NativeCommands>({
  supportedCommands: ['resolveCommand'],
});

export default codegenNativeComponent<NativeProps>('YaloChatView');
