// Copyright (c) Yalochat, Inc. All rights reserved.

// The web build takes its host from VITE_YALO_API_BASE_URL; the CLI has no
// build step, so the same hosts live here. Both are bare hosts: the services
// prepend https:// and append /v1/channels themselves.
export const HOSTS = {
  prod: 'api2-ww-us-001.yalochat.com/public-api-gateway',
  staging: 'api-staging2.yalochat.com/public-api-gateway',
} as const;

export type Env = keyof typeof HOSTS;

export function isEnv(value: string): value is Env {
  return Object.hasOwn(HOSTS, value);
}
