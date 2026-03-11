// Copyright (c) Yalochat, Inc. All rights reserved.

import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import Logger from './logger';

const PREFIX = '[YaloChatSDK]';

describe('Logger', () => {
  let logger: Logger;
  let consoleDebug: ReturnType<typeof vi.spyOn>;
  let consoleInfo: ReturnType<typeof vi.spyOn>;
  let consoleWarn: ReturnType<typeof vi.spyOn>;
  let consoleError: ReturnType<typeof vi.spyOn>;

  beforeEach(() => {
    logger = new Logger();
    consoleDebug = vi.spyOn(console, 'debug').mockImplementation(() => {});
    consoleInfo = vi.spyOn(console, 'info').mockImplementation(() => {});
    consoleWarn = vi.spyOn(console, 'warn').mockImplementation(() => {});
    consoleError = vi.spyOn(console, 'error').mockImplementation(() => {});
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  describe('prefix', () => {
    it('prepends [YaloChatSDK] to every log call', () => {
      logger.currentLevel = 'debug';
      logger.debug('hello');
      expect(consoleDebug).toHaveBeenCalledWith(PREFIX, 'hello');
    });

    it('supports multiple arguments', () => {
      logger.currentLevel = 'debug';
      logger.debug('a', 'b', 'c');
      expect(consoleDebug).toHaveBeenCalledWith(PREFIX, 'a', 'b', 'c');
    });
  });

  describe('level filtering', () => {
    it('logs debug when currentLevel is debug', () => {
      logger.currentLevel = 'debug';
      logger.debug('msg');
      expect(consoleDebug).toHaveBeenCalledOnce();
    });

    it('suppresses debug when currentLevel is info', () => {
      logger.currentLevel = 'info';
      logger.debug('msg');
      expect(consoleDebug).not.toHaveBeenCalled();
    });

    it('suppresses debug and info when currentLevel is warn', () => {
      logger.currentLevel = 'warn';
      logger.debug('msg');
      logger.info('msg');
      expect(consoleDebug).not.toHaveBeenCalled();
      expect(consoleInfo).not.toHaveBeenCalled();
    });

    it('only logs error when currentLevel is error', () => {
      logger.currentLevel = 'error';
      logger.debug('msg');
      logger.info('msg');
      logger.warn('msg');
      logger.error('msg');
      expect(consoleDebug).not.toHaveBeenCalled();
      expect(consoleInfo).not.toHaveBeenCalled();
      expect(consoleWarn).not.toHaveBeenCalled();
      expect(consoleError).toHaveBeenCalledOnce();
    });

    it('logs warn and above when currentLevel is warn', () => {
      logger.currentLevel = 'warn';
      logger.warn('msg');
      logger.error('msg');
      expect(consoleWarn).toHaveBeenCalledOnce();
      expect(consoleError).toHaveBeenCalledOnce();
    });
  });

  describe('methods', () => {
    beforeEach(() => {
      logger.currentLevel = 'debug';
    });

    it('calls console.debug for debug()', () => {
      logger.debug('test');
      expect(consoleDebug).toHaveBeenCalledWith(PREFIX, 'test');
    });

    it('calls console.info for info()', () => {
      logger.info('test');
      expect(consoleInfo).toHaveBeenCalledWith(PREFIX, 'test');
    });

    it('calls console.warn for warn()', () => {
      logger.warn('test');
      expect(consoleWarn).toHaveBeenCalledWith(PREFIX, 'test');
    });

    it('calls console.error for error()', () => {
      logger.error('test');
      expect(consoleError).toHaveBeenCalledWith(PREFIX, 'test');
    });
  });
});
