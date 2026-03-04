// Copyright (c) Yalochat, Inc. All rights reserved.

const LOG_LEVELS = ['debug', 'info', 'warn', 'error'] as const;
type LogLevel = typeof LOG_LEVELS[number];

const currentLevel: LogLevel = import.meta.env.DEV ? 'debug' : 'warn';

export function createLogger(className?: string) {
  const prefix = className ? `[YaloChatSDK:${className}]` : '[YaloChatSDK]';

  function log(level: LogLevel, args: unknown[]) {
    if (LOG_LEVELS.indexOf(level) >= LOG_LEVELS.indexOf(currentLevel)) {
      console[level](prefix, ...args);
    }
  }

  return {
    debug: (...args: unknown[]) => log('debug', args),
    info:  (...args: unknown[]) => log('info',  args),
    warn:  (...args: unknown[]) => log('warn',  args),
    error: (...args: unknown[]) => log('error', args),
  };
}
