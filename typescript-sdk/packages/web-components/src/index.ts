// Copyright (c) Yalochat, Inc. All rights reserved.
// Public API for @yalo/chat-sdk

// Theme
export { defaultChatTheme, applyTheme } from './theme/chat-theme.js';
export type { ChatTheme } from './theme/chat-theme.js';
export { SdkColors } from './theme/colors.js';
export { SdkConstants } from './theme/constants.js';

// Register all custom elements
import './components/yalo-chat.js';
import './components/chat-app-bar.js';
import './components/message-list.js';
import './components/messages/message.js';
import './components/messages/user-message.js';
import './components/messages/user-image-message.js';
import './components/messages/user-voice-message.js';
import './components/messages/assistant-message.js';
import './components/messages/assistant-product-message.js';
import './components/messages/product-vertical-card.js';
import './components/messages/product-horizontal-card.js';
import './components/messages/product-message-price.js';
import './components/messages/numeric-text-field.js';
import './components/messages/expand-button.js';
import './components/messages/image-placeholder.js';
import './components/chat-input/chat-input.js';
import './components/chat-input/action-button.js';
import './components/chat-input/attachment-button.js';
import './components/chat-input/quick-reply.js';
import './components/chat-input/image-preview.js';
import './components/chat-input/waveform-recorder.js';
import './components/chat-input/picker-button.js';

// Re-export component types (not values — they auto-register on import)
export type { YaloChat } from './components/yalo-chat.js';
export type { YaloChatAppBar } from './components/chat-app-bar.js';
export type { YaloMessageList } from './components/message-list.js';
