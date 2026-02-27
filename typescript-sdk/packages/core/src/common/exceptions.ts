// Copyright (c) Yalochat, Inc. All rights reserved.

/** Thrown when a required permission (microphone, camera) is denied. */
export class PermissionException extends Error {
  constructor(message = 'Permission denied') {
    super(message);
    this.name = 'PermissionException';
  }
}

/** Thrown when a value is outside an accepted range. */
export class RangeException extends Error {
  constructor(message = 'Value out of range') {
    super(message);
    this.name = 'RangeException';
  }
}
