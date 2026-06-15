// Copyright (c) Yalochat, Inc. All rights reserved.

const LOG_LEVELS = ['debug', 'info', 'warn', 'error'] as const;
export type LogLevel = (typeof LOG_LEVELS)[number];

export default class Logger {
  private readonly _prefix = '[YaloChatSDK]';

  currentLevel: LogLevel = 'warn';

  private _log(level: LogLevel, args: unknown[]) {
    if (LOG_LEVELS.indexOf(level) >= LOG_LEVELS.indexOf(this.currentLevel)) {
      console[level](this._prefix, ...args);
    }
  }

  debug = (...args: unknown[]) => this._log('debug', args);
  info = (...args: unknown[]) => this._log('info', args);
  warn = (...args: unknown[]) => this._log('warn', args);
  error = (...args: unknown[]) => this._log('error', args);
}
