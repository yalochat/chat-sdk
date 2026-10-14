// Copyright (c) Yalochat, Inc. All rights reserved.
import type * as React from 'react';
import {
  codegenNativeCommands,
  codegenNativeComponent,
  type CodegenTypes,
  type HostComponent,
  type ViewProps,
} from 'react-native';

export type CommandEvent = Readonly<{
  requestId: string;
  command: string;
  payload: string;
}>;

interface NativeProps extends ViewProps {
  config: string;
  theme: string;
  showsBackButton?: CodegenTypes.WithDefault<boolean, false>;
  commands?: ReadonlyArray<string>;
  onBack?: CodegenTypes.DirectEventHandler<Readonly<{}>>;
  onCommand?: CodegenTypes.DirectEventHandler<CommandEvent>;
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
