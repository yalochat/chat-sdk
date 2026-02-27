const base = require('../../jest.config.base.js');

/** @type {import('jest').Config} */
module.exports = {
  ...base,
  testEnvironment: 'node',
  roots: ['<rootDir>/src'],
  moduleNameMapper: {
    // Strip .js extensions so Jest resolves .ts source files
    '^(\\.{1,2}/.*)\\.js$': '$1',
  },
};
