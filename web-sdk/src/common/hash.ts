// Copyright (c) Yalochat, Inc. All rights reserved.

// xxhash32 over the UTF-8 bytes of `input`, base36-encoded.
// Reference: https://github.com/Cyan4973/xxHash/blob/dev/doc/xxhash_spec.md

const P1 = -1640531535; // 0x9E3779B1 interpreted as int32
const P2 = -2048144777; // 0x85EBCA77
const P3 = -1028477379; // 0xC2B2AE3D
const P4 = 668265263; //   0x27D4EB2F
const P5 = 374761393; //   0x165667B1

export function xxhash32(input: string): string {
  const data = new TextEncoder().encode(input);
  const len = data.length;
  let i = 0;
  let h32: number;

  if (len >= 16) {
    let v1 = (P1 + P2) | 0;
    let v2 = P2 | 0;
    let v3 = 0;
    let v4 = -P1 | 0;
    const limit = len - 16;
    do {
      v1 = round(v1, readU32LE(data, i));
      v2 = round(v2, readU32LE(data, i + 4));
      v3 = round(v3, readU32LE(data, i + 8));
      v4 = round(v4, readU32LE(data, i + 12));
      i += 16;
    } while (i <= limit);
    h32 = (rotl(v1, 1) + rotl(v2, 7) + rotl(v3, 12) + rotl(v4, 18)) | 0;
  } else {
    h32 = P5;
  }

  h32 = (h32 + len) | 0;

  while (i + 4 <= len) {
    h32 = (h32 + Math.imul(readU32LE(data, i), P3)) | 0;
    h32 = Math.imul(rotl(h32, 17), P4);
    i += 4;
  }

  while (i < len) {
    h32 = (h32 + Math.imul(data[i], P5)) | 0;
    h32 = Math.imul(rotl(h32, 11), P1);
    i += 1;
  }

  h32 ^= h32 >>> 15;
  h32 = Math.imul(h32, P2);
  h32 ^= h32 >>> 13;
  h32 = Math.imul(h32, P3);
  h32 ^= h32 >>> 16;

  return (h32 >>> 0).toString(36);
}

function round(acc: number, lane: number): number {
  acc = (acc + Math.imul(lane, P2)) | 0;
  acc = rotl(acc, 13);
  return Math.imul(acc, P1);
}

function rotl(x: number, n: number): number {
  return (x << n) | (x >>> (32 - n));
}

function readU32LE(data: Uint8Array, offset: number): number {
  return (
    data[offset] |
    (data[offset + 1] << 8) |
    (data[offset + 2] << 16) |
    (data[offset + 3] << 24)
  );
}
