// Copyright (c) Yalochat, Inc. All rights reserved.

export interface SdkIcons {
  close?: string;
  send?: string;
  mic?: string;
  attachment?: string;
  play?: string;
  pause?: string;
}

export interface YaloChatClientConfig {
  channelId: string;
  organizationId: string;
  channelName: string;
  target: string;
  image?: string;
  locale?: string;
  icons?: SdkIcons;
  audioWaveformColor?: string;
}

export const defaultIcons: SdkIcons = {
  close: '<span class="material-symbols-outlined">close</span>',
  send: '<span class="material-symbols-outlined">send</span>',
  mic: '<span class="material-symbols-outlined">mic</span>',
  attachment: '<span class="material-symbols-outlined">add</span>',
  play: '<span class="material-symbols-outlined">play_arrow</span>',
  pause: '<span class="material-symbols-outlined">pause</span>',
};
