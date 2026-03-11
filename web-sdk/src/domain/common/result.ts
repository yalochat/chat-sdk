// Copyright (c) Yalochat, Inc. All rights reserved.

export class Ok<T> {
  readonly ok = true as const;
  readonly value: T;

  constructor(value: T) {
    this.value = value;
  }
}

export class Err {
  readonly ok = false as const;
  readonly error: Error;

  constructor(error: Error) {
    this.error = error;
  }
}

export type Result<T> = Ok<T> | Err;
