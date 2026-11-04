// Copyright (c) Yalochat, Inc. All rights reserved.
/* global jest */
jest.mock('./src/NativeYaloChat', () => ({
  __esModule: true,
  default: {
    clearMessages: jest.fn(() => Promise.resolve()),
    logout: jest.fn(() => Promise.resolve()),
  },
}));
