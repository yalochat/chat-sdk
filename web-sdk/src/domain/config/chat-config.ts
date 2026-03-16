// Copyright (c) Yalochat, Inc. All rights reserved.

export interface SdkIcons {
  close?: string;
  send?: string;
}

export interface YaloChatClientConfig {
  channelId: string;
  organizationId: string;
  channelName: string;
  target: string;
  image?: string;
  locale?: string;
  icons?: SdkIcons;
}

export const defaultIcons: SdkIcons = {
  close: '<span class="material-symbols-outlined">close</span>',
  send: '<span class="material-symbols-outlined">send</span>',
};
