// Copyright (c) Yalochat, Inc. All rights reserved.
import { describe, expect, it, jest } from '@jest/globals';
import { PlatformColor, processColor } from 'react-native';
import { serializeTheme } from '../ChatTheme';

describe('serializeTheme', () => {
  it('sends colors as the numbers the platform reads', () => {
    const native = JSON.parse(
      serializeTheme({ headerBackground: '#ff0000', linkColor: 'blue' })
    );

    expect(native).toEqual({
      headerBackground: processColor('#ff0000'),
      linkColor: processColor('blue'),
    });
  });

  it('rounds every corner when a shape is a number', () => {
    const native = JSON.parse(serializeTheme({ inputShape: 12 }));

    expect(native).toEqual({
      inputShape: { topStart: 12, topEnd: 12, bottomEnd: 12, bottomStart: 12 },
    });
  });

  it('leaves the corners a shape does not name square', () => {
    const native = JSON.parse(
      serializeTheme({
        userMessageShape: { topStart: 18, bottomEnd: 4 },
        imageShape: {},
      })
    );

    expect(native).toEqual({
      userMessageShape: {
        topStart: 18,
        topEnd: 0,
        bottomEnd: 4,
        bottomStart: 0,
      },
      imageShape: { topStart: 0, topEnd: 0, bottomEnd: 0, bottomStart: 0 },
    });
  });

  it('keeps every corner a shape names', () => {
    const corners = { topStart: 1, topEnd: 2, bottomEnd: 3, bottomStart: 4 };

    const native = JSON.parse(serializeTheme({ postbackShape: corners }));

    expect(native).toEqual({ postbackShape: corners });
  });

  it('leaves out what was not set', () => {
    expect(serializeTheme({ background: undefined })).toBe('{}');
  });

  it('ignores colors the platform cannot turn into a number', () => {
    const warn = jest.spyOn(console, 'warn').mockImplementation(() => {});

    const native = JSON.parse(
      serializeTheme({ background: PlatformColor('systemBlue') })
    );

    expect(native).toEqual({});
    expect(warn).toHaveBeenCalledWith(
      expect.stringContaining('background is not a plain color')
    );
    warn.mockRestore();
  });
});
