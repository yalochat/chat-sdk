// Copyright (c) Yalochat, Inc. All rights reserved.
import { TurboModuleRegistry, type TurboModule } from 'react-native';

export interface Spec extends TurboModule {
  clearMessages(config: string): Promise<void>;
  logout(config: string): Promise<void>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('YaloChat');
