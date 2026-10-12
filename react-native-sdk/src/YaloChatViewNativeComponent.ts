// Copyright (c) Yalochat, Inc. All rights reserved.
import {
  codegenNativeComponent,
  type CodegenTypes,
  type ViewProps,
} from 'react-native';

interface NativeProps extends ViewProps {
  config: string;
  theme: string;
  showsBackButton?: CodegenTypes.WithDefault<boolean, false>;
  onBack?: CodegenTypes.DirectEventHandler<Readonly<{}>>;
}

export default codegenNativeComponent<NativeProps>('YaloChatView');
