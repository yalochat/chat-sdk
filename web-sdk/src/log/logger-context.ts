import { createContext } from '@lit/context';

import type Logger from './logger';

export type { default as Logger } from './logger';

export const loggerContext = createContext<Logger>(Symbol('logger'));
