// Copyright (c) Yalochat, Inc. All rights reserved.

import { defaultChatTheme, applyTheme } from '../theme/chat-theme';
import { SdkColors } from '../theme/colors';

describe('defaultChatTheme', () => {
  it('has the correct send button color', () => {
    expect(defaultChatTheme.sendButtonColor).toBe(SdkColors.sendButtonColorLight);
  });

  it('has the correct background color', () => {
    expect(defaultChatTheme.backgroundColor).toBe(SdkColors.backgroundColorLight);
  });
});

describe('applyTheme', () => {
  it('sets CSS custom properties on the element', () => {
    const el = document.createElement('div');
    applyTheme(defaultChatTheme, el);
    expect(el.style.getPropertyValue('--yalo-send-btn-color')).toBe(defaultChatTheme.sendButtonColor);
    expect(el.style.getPropertyValue('--yalo-bg-color')).toBe(defaultChatTheme.backgroundColor);
  });
});
