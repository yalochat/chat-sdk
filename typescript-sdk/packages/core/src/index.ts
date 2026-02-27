// Copyright (c) Yalochat, Inc. All rights reserved.
// Public API for @yalo/chat-sdk-core

// Common
export * from './common/result.js';
export * from './common/page.js';
export * from './common/format.js';
export * from './common/exceptions.js';

// Domain
export * from './domain/chat-message.js';
export * from './domain/product.js';
export * from './domain/audio-data.js';
export * from './domain/image-data.js';
export * from './domain/chat-event.js';
export * from './domain/yalo-message.js';

// Use cases
export * from './use-cases/audio-processing.js';

// Client
export * from './data/client/yalo-chat-client.js';

// Services (interfaces only — implementations are tree-shaken)
export type { AudioService, AmplitudeCallback } from './data/services/audio/audio-service.js';
export type { CameraService } from './data/services/camera/camera-service.js';
export { IdbService } from './data/services/database/idb-service.js';
export { AudioServiceWeb } from './data/services/audio/audio-service-web.js';
export { CameraServiceWeb } from './data/services/camera/camera-service-web.js';

// Repositories (interfaces)
export type { ChatMessageRepository } from './data/repositories/chat-message/chat-message-repository.js';
export type { YaloMessageRepository, MessageCallback, EventCallback } from './data/repositories/yalo-message/yalo-message-repository.js';
export type { ImageRepository } from './data/repositories/image/image-repository.js';
export type { AudioRepository } from './data/repositories/audio/audio-repository.js';

// Repository implementations
export { ChatMessageRepositoryIdb } from './data/repositories/chat-message/chat-message-repository-idb.js';
export { YaloMessageRepositoryRemote } from './data/repositories/yalo-message/yalo-message-repository-remote.js';
export { YaloMessageRepositoryFake } from './data/repositories/yalo-message/yalo-message-repository-fake.js';
export { ImageRepositoryWeb } from './data/repositories/image/image-repository-web.js';
export { AudioRepositoryWeb } from './data/repositories/audio/audio-repository-web.js';

// Stores
export { ChatStore, initialChatState } from './store/chat-store.js';
export type { ChatState, ChatStatus, ChatDependencies } from './store/chat-store.js';
export { AudioStore } from './store/audio-store.js';
export type { AudioState, AudioStatus } from './store/audio-store.js';
export { ImageStore } from './store/image-store.js';
export type { ImageState, ImageStatus } from './store/image-store.js';
