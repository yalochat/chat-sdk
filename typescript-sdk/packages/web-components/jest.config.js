const base = require('../../jest.config.base.js');

/** @type {import('jest').Config} */
module.exports = {
  ...base,
  testEnvironment: 'jsdom',
  roots: ['<rootDir>/src'],
  moduleNameMapper: {
    '^@yalo/chat-sdk-core$': '<rootDir>/../core/src/index.ts',
    '^@yalo/chat-sdk-core/(.*)$': '<rootDir>/../core/src/$1',
    // Strip .js extensions so Jest resolves .ts source files
    '^(\\.{1,2}/.*)\\.js$': '$1',
  },
};
