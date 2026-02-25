// Copyright (c) Yalochat, Inc. All rights reserved.


class PermissionException implements Exception {
  final String message;

  PermissionException(String permissionName)
    : message =
          'no $permissionName allowed';
}
