// This is a generated file - do not edit.
//
// Generated from events/external_channel/in_app/sdk/sdk_message.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use responseStatusDescriptor instead')
const ResponseStatus$json = {
  '1': 'ResponseStatus',
  '2': [
    {'1': 'RESPONSE_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'RESPONSE_STATUS_SUCCESS', '2': 1},
    {'1': 'RESPONSE_STATUS_ERROR', '2': 2},
  ],
};

/// Descriptor for `ResponseStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List responseStatusDescriptor = $convert.base64Decode(
    'Cg5SZXNwb25zZVN0YXR1cxIfChtSRVNQT05TRV9TVEFUVVNfVU5TUEVDSUZJRUQQABIbChdSRV'
    'NQT05TRV9TVEFUVVNfU1VDQ0VTUxABEhkKFVJFU1BPTlNFX1NUQVRVU19FUlJPUhAC');

@$core.Deprecated('Use messageRoleDescriptor instead')
const MessageRole$json = {
  '1': 'MessageRole',
  '2': [
    {'1': 'MESSAGE_ROLE_UNSPECIFIED', '2': 0},
    {'1': 'MESSAGE_ROLE_USER', '2': 1},
    {'1': 'MESSAGE_ROLE_AGENT', '2': 2},
  ],
};

/// Descriptor for `MessageRole`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List messageRoleDescriptor = $convert.base64Decode(
    'CgtNZXNzYWdlUm9sZRIcChhNRVNTQUdFX1JPTEVfVU5TUEVDSUZJRUQQABIVChFNRVNTQUdFX1'
    'JPTEVfVVNFUhABEhYKEk1FU1NBR0VfUk9MRV9BR0VOVBAC');

@$core.Deprecated('Use unitTypeDescriptor instead')
const UnitType$json = {
  '1': 'UnitType',
  '2': [
    {'1': 'UNIT_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'UNIT_TYPE_UNIT', '2': 1},
    {'1': 'UNIT_TYPE_SUBUNIT', '2': 2},
  ],
};

/// Descriptor for `UnitType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List unitTypeDescriptor = $convert.base64Decode(
    'CghVbml0VHlwZRIZChVVTklUX1RZUEVfVU5TUEVDSUZJRUQQABISCg5VTklUX1RZUEVfVU5JVB'
    'ABEhUKEVVOSVRfVFlQRV9TVUJVTklUEAI=');

@$core.Deprecated('Use messageStatusDescriptor instead')
const MessageStatus$json = {
  '1': 'MessageStatus',
  '2': [
    {'1': 'MESSAGE_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'MESSAGE_STATUS_DELIVERED', '2': 1},
    {'1': 'MESSAGE_STATUS_IN_PROGRESS', '2': 2},
    {'1': 'MESSAGE_STATUS_READ', '2': 3},
    {'1': 'MESSAGE_STATUS_ERROR', '2': 4},
    {'1': 'MESSAGE_STATUS_SENT', '2': 5},
    {'1': 'MESSAGE_STATUS_IN_DELIVERY', '2': 6},
  ],
};

/// Descriptor for `MessageStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List messageStatusDescriptor = $convert.base64Decode(
    'Cg1NZXNzYWdlU3RhdHVzEh4KGk1FU1NBR0VfU1RBVFVTX1VOU1BFQ0lGSUVEEAASHAoYTUVTU0'
    'FHRV9TVEFUVVNfREVMSVZFUkVEEAESHgoaTUVTU0FHRV9TVEFUVVNfSU5fUFJPR1JFU1MQAhIX'
    'ChNNRVNTQUdFX1NUQVRVU19SRUFEEAMSGAoUTUVTU0FHRV9TVEFUVVNfRVJST1IQBBIXChNNRV'
    'NTQUdFX1NUQVRVU19TRU5UEAUSHgoaTUVTU0FHRV9TVEFUVVNfSU5fREVMSVZFUlkQBg==');

@$core.Deprecated('Use buttonTypeDescriptor instead')
const ButtonType$json = {
  '1': 'ButtonType',
  '2': [
    {'1': 'BUTTON_TYPE_REPLY', '2': 0},
    {'1': 'BUTTON_TYPE_POSTBACK', '2': 1},
    {'1': 'BUTTON_TYPE_LINK', '2': 2},
  ],
};

/// Descriptor for `ButtonType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List buttonTypeDescriptor = $convert.base64Decode(
    'CgpCdXR0b25UeXBlEhUKEUJVVFRPTl9UWVBFX1JFUExZEAASGAoUQlVUVE9OX1RZUEVfUE9TVE'
    'JBQ0sQARIUChBCVVRUT05fVFlQRV9MSU5LEAI=');

@$core.Deprecated('Use sdkCommandDescriptor instead')
const SdkCommand$json = {
  '1': 'SdkCommand',
  '2': [
    {'1': 'SDK_COMMAND_UNSPECIFIED', '2': 0},
    {'1': 'SDK_COMMAND_ADD_TO_CART', '2': 1},
    {'1': 'SDK_COMMAND_REMOVE_FROM_CART', '2': 2},
    {'1': 'SDK_COMMAND_CLEAR_CART', '2': 3},
    {'1': 'SDK_COMMAND_GUIDANCE_CARD', '2': 4},
    {'1': 'SDK_COMMAND_ADD_PROMOTION', '2': 5},
  ],
};

/// Descriptor for `SdkCommand`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List sdkCommandDescriptor = $convert.base64Decode(
    'CgpTZGtDb21tYW5kEhsKF1NES19DT01NQU5EX1VOU1BFQ0lGSUVEEAASGwoXU0RLX0NPTU1BTk'
    'RfQUREX1RPX0NBUlQQARIgChxTREtfQ09NTUFORF9SRU1PVkVfRlJPTV9DQVJUEAISGgoWU0RL'
    'X0NPTU1BTkRfQ0xFQVJfQ0FSVBADEh0KGVNES19DT01NQU5EX0dVSURBTkNFX0NBUkQQBBIdCh'
    'lTREtfQ09NTUFORF9BRERfUFJPTU9USU9OEAU=');

@$core.Deprecated('Use sdkMessageDescriptor instead')
const SdkMessage$json = {
  '1': 'SdkMessage',
  '2': [
    {'1': 'correlation_id', '3': 1, '4': 1, '5': 9, '10': 'correlationId'},
    {
      '1': 'timestamp',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
    {
      '1': 'text_message_request',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v2.TextMessageRequest',
      '9': 0,
      '10': 'textMessageRequest'
    },
    {
      '1': 'voice_note_message_request',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v2.VoiceNoteMessageRequest',
      '9': 0,
      '10': 'voiceNoteMessageRequest'
    },
    {
      '1': 'image_message_request',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v2.ImageMessageRequest',
      '9': 0,
      '10': 'imageMessageRequest'
    },
    {
      '1': 'message_receipt_request',
      '3': 16,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v2.MessageReceiptRequest',
      '9': 0,
      '10': 'messageReceiptRequest'
    },
    {
      '1': 'attachment_message_request',
      '3': 18,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v2.AttachmentMessageRequest',
      '9': 0,
      '10': 'attachmentMessageRequest'
    },
    {
      '1': 'video_message_request',
      '3': 38,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v2.VideoMessageRequest',
      '9': 0,
      '10': 'videoMessageRequest'
    },
    {
      '1': 'add_to_cart_request',
      '3': 20,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v2.AddToCartRequest',
      '9': 0,
      '10': 'addToCartRequest'
    },
    {
      '1': 'add_to_cart_response',
      '3': 21,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v2.AddToCartResponse',
      '9': 0,
      '10': 'addToCartResponse'
    },
    {
      '1': 'remove_from_cart_request',
      '3': 22,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v2.RemoveFromCartRequest',
      '9': 0,
      '10': 'removeFromCartRequest'
    },
    {
      '1': 'remove_from_cart_response',
      '3': 23,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v2.RemoveFromCartResponse',
      '9': 0,
      '10': 'removeFromCartResponse'
    },
    {
      '1': 'clear_cart_request',
      '3': 24,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v2.ClearCartRequest',
      '9': 0,
      '10': 'clearCartRequest'
    },
    {
      '1': 'clear_cart_response',
      '3': 25,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v2.ClearCartResponse',
      '9': 0,
      '10': 'clearCartResponse'
    },
    {
      '1': 'guidance_card_request',
      '3': 26,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v2.GuidanceCardRequest',
      '9': 0,
      '10': 'guidanceCardRequest'
    },
    {
      '1': 'guidance_card_response',
      '3': 27,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v2.GuidanceCardResponse',
      '9': 0,
      '10': 'guidanceCardResponse'
    },
    {
      '1': 'add_promotion_request',
      '3': 28,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v2.AddPromotionRequest',
      '9': 0,
      '10': 'addPromotionRequest'
    },
    {
      '1': 'add_promotion_response',
      '3': 29,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v2.AddPromotionResponse',
      '9': 0,
      '10': 'addPromotionResponse'
    },
    {
      '1': 'promotion_message_request',
      '3': 30,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v2.PromotionMessageRequest',
      '9': 0,
      '10': 'promotionMessageRequest'
    },
    {
      '1': 'promotion_message_response',
      '3': 31,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v2.PromotionMessageResponse',
      '9': 0,
      '10': 'promotionMessageResponse'
    },
    {
      '1': 'product_message_request',
      '3': 32,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v2.ProductMessageRequest',
      '9': 0,
      '10': 'productMessageRequest'
    },
    {
      '1': 'product_message_response',
      '3': 33,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v2.ProductMessageResponse',
      '9': 0,
      '10': 'productMessageResponse'
    },
    {
      '1': 'chat_status_request',
      '3': 34,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v2.ChatStatusRequest',
      '9': 0,
      '10': 'chatStatusRequest'
    },
    {
      '1': 'chat_status_response',
      '3': 35,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v2.ChatStatusResponse',
      '9': 0,
      '10': 'chatStatusResponse'
    },
    {
      '1': 'custom_command_request',
      '3': 36,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v2.CustomCommandRequest',
      '9': 0,
      '10': 'customCommandRequest'
    },
    {
      '1': 'custom_command_response',
      '3': 37,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v2.CustomCommandResponse',
      '9': 0,
      '10': 'customCommandResponse'
    },
    {
      '1': 'get_commands_request',
      '3': 44,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v2.GetCommandsRequest',
      '9': 0,
      '10': 'getCommandsRequest'
    },
    {
      '1': 'get_commands_response',
      '3': 45,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v2.GetCommandsResponse',
      '9': 0,
      '10': 'getCommandsResponse'
    },
  ],
  '8': [
    {'1': 'payload'},
  ],
};

/// Descriptor for `SdkMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sdkMessageDescriptor = $convert.base64Decode(
    'CgpTZGtNZXNzYWdlEiUKDmNvcnJlbGF0aW9uX2lkGAEgASgJUg1jb3JyZWxhdGlvbklkEjgKCX'
    'RpbWVzdGFtcBgCIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCXRpbWVzdGFtcBJr'
    'ChR0ZXh0X21lc3NhZ2VfcmVxdWVzdBgKIAEoCzI3LnlhbG8uZXh0ZXJuYWxfY2hhbm5lbC5pbl'
    '9hcHAuc2RrLnYyLlRleHRNZXNzYWdlUmVxdWVzdEgAUhJ0ZXh0TWVzc2FnZVJlcXVlc3QSewoa'
    'dm9pY2Vfbm90ZV9tZXNzYWdlX3JlcXVlc3QYDCABKAsyPC55YWxvLmV4dGVybmFsX2NoYW5uZW'
    'wuaW5fYXBwLnNkay52Mi5Wb2ljZU5vdGVNZXNzYWdlUmVxdWVzdEgAUhd2b2ljZU5vdGVNZXNz'
    'YWdlUmVxdWVzdBJuChVpbWFnZV9tZXNzYWdlX3JlcXVlc3QYDiABKAsyOC55YWxvLmV4dGVybm'
    'FsX2NoYW5uZWwuaW5fYXBwLnNkay52Mi5JbWFnZU1lc3NhZ2VSZXF1ZXN0SABSE2ltYWdlTWVz'
    'c2FnZVJlcXVlc3QSdAoXbWVzc2FnZV9yZWNlaXB0X3JlcXVlc3QYECABKAsyOi55YWxvLmV4dG'
    'VybmFsX2NoYW5uZWwuaW5fYXBwLnNkay52Mi5NZXNzYWdlUmVjZWlwdFJlcXVlc3RIAFIVbWVz'
    'c2FnZVJlY2VpcHRSZXF1ZXN0En0KGmF0dGFjaG1lbnRfbWVzc2FnZV9yZXF1ZXN0GBIgASgLMj'
    '0ueWFsby5leHRlcm5hbF9jaGFubmVsLmluX2FwcC5zZGsudjIuQXR0YWNobWVudE1lc3NhZ2VS'
    'ZXF1ZXN0SABSGGF0dGFjaG1lbnRNZXNzYWdlUmVxdWVzdBJuChV2aWRlb19tZXNzYWdlX3JlcX'
    'Vlc3QYJiABKAsyOC55YWxvLmV4dGVybmFsX2NoYW5uZWwuaW5fYXBwLnNkay52Mi5WaWRlb01l'
    'c3NhZ2VSZXF1ZXN0SABSE3ZpZGVvTWVzc2FnZVJlcXVlc3QSZgoTYWRkX3RvX2NhcnRfcmVxdW'
    'VzdBgUIAEoCzI1LnlhbG8uZXh0ZXJuYWxfY2hhbm5lbC5pbl9hcHAuc2RrLnYyLkFkZFRvQ2Fy'
    'dFJlcXVlc3RIAFIQYWRkVG9DYXJ0UmVxdWVzdBJpChRhZGRfdG9fY2FydF9yZXNwb25zZRgVIA'
    'EoCzI2LnlhbG8uZXh0ZXJuYWxfY2hhbm5lbC5pbl9hcHAuc2RrLnYyLkFkZFRvQ2FydFJlc3Bv'
    'bnNlSABSEWFkZFRvQ2FydFJlc3BvbnNlEnUKGHJlbW92ZV9mcm9tX2NhcnRfcmVxdWVzdBgWIA'
    'EoCzI6LnlhbG8uZXh0ZXJuYWxfY2hhbm5lbC5pbl9hcHAuc2RrLnYyLlJlbW92ZUZyb21DYXJ0'
    'UmVxdWVzdEgAUhVyZW1vdmVGcm9tQ2FydFJlcXVlc3QSeAoZcmVtb3ZlX2Zyb21fY2FydF9yZX'
    'Nwb25zZRgXIAEoCzI7LnlhbG8uZXh0ZXJuYWxfY2hhbm5lbC5pbl9hcHAuc2RrLnYyLlJlbW92'
    'ZUZyb21DYXJ0UmVzcG9uc2VIAFIWcmVtb3ZlRnJvbUNhcnRSZXNwb25zZRJlChJjbGVhcl9jYX'
    'J0X3JlcXVlc3QYGCABKAsyNS55YWxvLmV4dGVybmFsX2NoYW5uZWwuaW5fYXBwLnNkay52Mi5D'
    'bGVhckNhcnRSZXF1ZXN0SABSEGNsZWFyQ2FydFJlcXVlc3QSaAoTY2xlYXJfY2FydF9yZXNwb2'
    '5zZRgZIAEoCzI2LnlhbG8uZXh0ZXJuYWxfY2hhbm5lbC5pbl9hcHAuc2RrLnYyLkNsZWFyQ2Fy'
    'dFJlc3BvbnNlSABSEWNsZWFyQ2FydFJlc3BvbnNlEm4KFWd1aWRhbmNlX2NhcmRfcmVxdWVzdB'
    'gaIAEoCzI4LnlhbG8uZXh0ZXJuYWxfY2hhbm5lbC5pbl9hcHAuc2RrLnYyLkd1aWRhbmNlQ2Fy'
    'ZFJlcXVlc3RIAFITZ3VpZGFuY2VDYXJkUmVxdWVzdBJxChZndWlkYW5jZV9jYXJkX3Jlc3Bvbn'
    'NlGBsgASgLMjkueWFsby5leHRlcm5hbF9jaGFubmVsLmluX2FwcC5zZGsudjIuR3VpZGFuY2VD'
    'YXJkUmVzcG9uc2VIAFIUZ3VpZGFuY2VDYXJkUmVzcG9uc2USbgoVYWRkX3Byb21vdGlvbl9yZX'
    'F1ZXN0GBwgASgLMjgueWFsby5leHRlcm5hbF9jaGFubmVsLmluX2FwcC5zZGsudjIuQWRkUHJv'
    'bW90aW9uUmVxdWVzdEgAUhNhZGRQcm9tb3Rpb25SZXF1ZXN0EnEKFmFkZF9wcm9tb3Rpb25fcm'
    'VzcG9uc2UYHSABKAsyOS55YWxvLmV4dGVybmFsX2NoYW5uZWwuaW5fYXBwLnNkay52Mi5BZGRQ'
    'cm9tb3Rpb25SZXNwb25zZUgAUhRhZGRQcm9tb3Rpb25SZXNwb25zZRJ6Chlwcm9tb3Rpb25fbW'
    'Vzc2FnZV9yZXF1ZXN0GB4gASgLMjwueWFsby5leHRlcm5hbF9jaGFubmVsLmluX2FwcC5zZGsu'
    'djIuUHJvbW90aW9uTWVzc2FnZVJlcXVlc3RIAFIXcHJvbW90aW9uTWVzc2FnZVJlcXVlc3QSfQ'
    'oacHJvbW90aW9uX21lc3NhZ2VfcmVzcG9uc2UYHyABKAsyPS55YWxvLmV4dGVybmFsX2NoYW5u'
    'ZWwuaW5fYXBwLnNkay52Mi5Qcm9tb3Rpb25NZXNzYWdlUmVzcG9uc2VIAFIYcHJvbW90aW9uTW'
    'Vzc2FnZVJlc3BvbnNlEnQKF3Byb2R1Y3RfbWVzc2FnZV9yZXF1ZXN0GCAgASgLMjoueWFsby5l'
    'eHRlcm5hbF9jaGFubmVsLmluX2FwcC5zZGsudjIuUHJvZHVjdE1lc3NhZ2VSZXF1ZXN0SABSFX'
    'Byb2R1Y3RNZXNzYWdlUmVxdWVzdBJ3Chhwcm9kdWN0X21lc3NhZ2VfcmVzcG9uc2UYISABKAsy'
    'Oy55YWxvLmV4dGVybmFsX2NoYW5uZWwuaW5fYXBwLnNkay52Mi5Qcm9kdWN0TWVzc2FnZVJlc3'
    'BvbnNlSABSFnByb2R1Y3RNZXNzYWdlUmVzcG9uc2USaAoTY2hhdF9zdGF0dXNfcmVxdWVzdBgi'
    'IAEoCzI2LnlhbG8uZXh0ZXJuYWxfY2hhbm5lbC5pbl9hcHAuc2RrLnYyLkNoYXRTdGF0dXNSZX'
    'F1ZXN0SABSEWNoYXRTdGF0dXNSZXF1ZXN0EmsKFGNoYXRfc3RhdHVzX3Jlc3BvbnNlGCMgASgL'
    'MjcueWFsby5leHRlcm5hbF9jaGFubmVsLmluX2FwcC5zZGsudjIuQ2hhdFN0YXR1c1Jlc3Bvbn'
    'NlSABSEmNoYXRTdGF0dXNSZXNwb25zZRJxChZjdXN0b21fY29tbWFuZF9yZXF1ZXN0GCQgASgL'
    'MjkueWFsby5leHRlcm5hbF9jaGFubmVsLmluX2FwcC5zZGsudjIuQ3VzdG9tQ29tbWFuZFJlcX'
    'Vlc3RIAFIUY3VzdG9tQ29tbWFuZFJlcXVlc3QSdAoXY3VzdG9tX2NvbW1hbmRfcmVzcG9uc2UY'
    'JSABKAsyOi55YWxvLmV4dGVybmFsX2NoYW5uZWwuaW5fYXBwLnNkay52Mi5DdXN0b21Db21tYW'
    '5kUmVzcG9uc2VIAFIVY3VzdG9tQ29tbWFuZFJlc3BvbnNlEmsKFGdldF9jb21tYW5kc19yZXF1'
    'ZXN0GCwgASgLMjcueWFsby5leHRlcm5hbF9jaGFubmVsLmluX2FwcC5zZGsudjIuR2V0Q29tbW'
    'FuZHNSZXF1ZXN0SABSEmdldENvbW1hbmRzUmVxdWVzdBJuChVnZXRfY29tbWFuZHNfcmVzcG9u'
    'c2UYLSABKAsyOC55YWxvLmV4dGVybmFsX2NoYW5uZWwuaW5fYXBwLnNkay52Mi5HZXRDb21tYW'
    '5kc1Jlc3BvbnNlSABSE2dldENvbW1hbmRzUmVzcG9uc2VCCQoHcGF5bG9hZA==');

@$core.Deprecated('Use buttonDescriptor instead')
const Button$json = {
  '1': 'Button',
  '2': [
    {'1': 'text', '3': 1, '4': 1, '5': 9, '10': 'text'},
    {
      '1': 'button_type',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.yalo.external_channel.in_app.sdk.v2.ButtonType',
      '10': 'buttonType'
    },
    {'1': 'url', '3': 3, '4': 1, '5': 9, '9': 0, '10': 'url', '17': true},
  ],
  '8': [
    {'1': '_url'},
  ],
};

/// Descriptor for `Button`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List buttonDescriptor = $convert.base64Decode(
    'CgZCdXR0b24SEgoEdGV4dBgBIAEoCVIEdGV4dBJQCgtidXR0b25fdHlwZRgCIAEoDjIvLnlhbG'
    '8uZXh0ZXJuYWxfY2hhbm5lbC5pbl9hcHAuc2RrLnYyLkJ1dHRvblR5cGVSCmJ1dHRvblR5cGUS'
    'FQoDdXJsGAMgASgJSABSA3VybIgBAUIGCgRfdXJs');

@$core.Deprecated('Use textMessageDescriptor instead')
const TextMessage$json = {
  '1': 'TextMessage',
  '2': [
    {
      '1': 'timestamp',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
    {'1': 'text', '3': 2, '4': 1, '5': 9, '10': 'text'},
    {
      '1': 'status',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.yalo.external_channel.in_app.sdk.v2.MessageStatus',
      '10': 'status'
    },
    {
      '1': 'role',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.yalo.external_channel.in_app.sdk.v2.MessageRole',
      '10': 'role'
    },
  ],
};

/// Descriptor for `TextMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List textMessageDescriptor = $convert.base64Decode(
    'CgtUZXh0TWVzc2FnZRI4Cgl0aW1lc3RhbXAYASABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZX'
    'N0YW1wUgl0aW1lc3RhbXASEgoEdGV4dBgCIAEoCVIEdGV4dBJKCgZzdGF0dXMYAyABKA4yMi55'
    'YWxvLmV4dGVybmFsX2NoYW5uZWwuaW5fYXBwLnNkay52Mi5NZXNzYWdlU3RhdHVzUgZzdGF0dX'
    'MSRAoEcm9sZRgEIAEoDjIwLnlhbG8uZXh0ZXJuYWxfY2hhbm5lbC5pbl9hcHAuc2RrLnYyLk1l'
    'c3NhZ2VSb2xlUgRyb2xl');

@$core.Deprecated('Use textMessageRequestDescriptor instead')
const TextMessageRequest$json = {
  '1': 'TextMessageRequest',
  '2': [
    {
      '1': 'content',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v2.TextMessage',
      '10': 'content'
    },
    {
      '1': 'timestamp',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
    {
      '1': 'buttons',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v2.Button',
      '10': 'buttons'
    },
    {'1': 'header', '3': 4, '4': 1, '5': 9, '9': 0, '10': 'header', '17': true},
    {'1': 'footer', '3': 5, '4': 1, '5': 9, '9': 1, '10': 'footer', '17': true},
  ],
  '8': [
    {'1': '_header'},
    {'1': '_footer'},
  ],
};

/// Descriptor for `TextMessageRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List textMessageRequestDescriptor = $convert.base64Decode(
    'ChJUZXh0TWVzc2FnZVJlcXVlc3QSSgoHY29udGVudBgBIAEoCzIwLnlhbG8uZXh0ZXJuYWxfY2'
    'hhbm5lbC5pbl9hcHAuc2RrLnYyLlRleHRNZXNzYWdlUgdjb250ZW50EjgKCXRpbWVzdGFtcBgC'
    'IAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCXRpbWVzdGFtcBJFCgdidXR0b25zGA'
    'MgAygLMisueWFsby5leHRlcm5hbF9jaGFubmVsLmluX2FwcC5zZGsudjIuQnV0dG9uUgdidXR0'
    'b25zEhsKBmhlYWRlchgEIAEoCUgAUgZoZWFkZXKIAQESGwoGZm9vdGVyGAUgASgJSAFSBmZvb3'
    'RlcogBAUIJCgdfaGVhZGVyQgkKB19mb290ZXI=');

@$core.Deprecated('Use voiceMessageDescriptor instead')
const VoiceMessage$json = {
  '1': 'VoiceMessage',
  '2': [
    {
      '1': 'timestamp',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
    {'1': 'media_url', '3': 2, '4': 1, '5': 9, '10': 'mediaUrl'},
    {
      '1': 'amplitudes_preview',
      '3': 3,
      '4': 3,
      '5': 2,
      '10': 'amplitudesPreview'
    },
    {'1': 'duration', '3': 4, '4': 1, '5': 1, '10': 'duration'},
    {'1': 'media_type', '3': 5, '4': 1, '5': 9, '10': 'mediaType'},
    {
      '1': 'status',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.yalo.external_channel.in_app.sdk.v2.MessageStatus',
      '10': 'status'
    },
    {
      '1': 'role',
      '3': 7,
      '4': 1,
      '5': 14,
      '6': '.yalo.external_channel.in_app.sdk.v2.MessageRole',
      '10': 'role'
    },
    {'1': 'byte_count', '3': 8, '4': 1, '5': 3, '10': 'byteCount'},
    {'1': 'file_name', '3': 9, '4': 1, '5': 9, '10': 'fileName'},
  ],
};

/// Descriptor for `VoiceMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List voiceMessageDescriptor = $convert.base64Decode(
    'CgxWb2ljZU1lc3NhZ2USOAoJdGltZXN0YW1wGAEgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbW'
    'VzdGFtcFIJdGltZXN0YW1wEhsKCW1lZGlhX3VybBgCIAEoCVIIbWVkaWFVcmwSLQoSYW1wbGl0'
    'dWRlc19wcmV2aWV3GAMgAygCUhFhbXBsaXR1ZGVzUHJldmlldxIaCghkdXJhdGlvbhgEIAEoAV'
    'IIZHVyYXRpb24SHQoKbWVkaWFfdHlwZRgFIAEoCVIJbWVkaWFUeXBlEkoKBnN0YXR1cxgGIAEo'
    'DjIyLnlhbG8uZXh0ZXJuYWxfY2hhbm5lbC5pbl9hcHAuc2RrLnYyLk1lc3NhZ2VTdGF0dXNSBn'
    'N0YXR1cxJECgRyb2xlGAcgASgOMjAueWFsby5leHRlcm5hbF9jaGFubmVsLmluX2FwcC5zZGsu'
    'djIuTWVzc2FnZVJvbGVSBHJvbGUSHQoKYnl0ZV9jb3VudBgIIAEoA1IJYnl0ZUNvdW50EhsKCW'
    'ZpbGVfbmFtZRgJIAEoCVIIZmlsZU5hbWU=');

@$core.Deprecated('Use voiceNoteMessageRequestDescriptor instead')
const VoiceNoteMessageRequest$json = {
  '1': 'VoiceNoteMessageRequest',
  '2': [
    {
      '1': 'content',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v2.VoiceMessage',
      '10': 'content'
    },
    {
      '1': 'timestamp',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
    {
      '1': 'buttons',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v2.Button',
      '10': 'buttons'
    },
    {'1': 'header', '3': 4, '4': 1, '5': 9, '9': 0, '10': 'header', '17': true},
    {'1': 'footer', '3': 5, '4': 1, '5': 9, '9': 1, '10': 'footer', '17': true},
  ],
  '8': [
    {'1': '_header'},
    {'1': '_footer'},
  ],
};

/// Descriptor for `VoiceNoteMessageRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List voiceNoteMessageRequestDescriptor = $convert.base64Decode(
    'ChdWb2ljZU5vdGVNZXNzYWdlUmVxdWVzdBJLCgdjb250ZW50GAEgASgLMjEueWFsby5leHRlcm'
    '5hbF9jaGFubmVsLmluX2FwcC5zZGsudjIuVm9pY2VNZXNzYWdlUgdjb250ZW50EjgKCXRpbWVz'
    'dGFtcBgCIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCXRpbWVzdGFtcBJFCgdidX'
    'R0b25zGAMgAygLMisueWFsby5leHRlcm5hbF9jaGFubmVsLmluX2FwcC5zZGsudjIuQnV0dG9u'
    'UgdidXR0b25zEhsKBmhlYWRlchgEIAEoCUgAUgZoZWFkZXKIAQESGwoGZm9vdGVyGAUgASgJSA'
    'FSBmZvb3RlcogBAUIJCgdfaGVhZGVyQgkKB19mb290ZXI=');

@$core.Deprecated('Use imageMessageDescriptor instead')
const ImageMessage$json = {
  '1': 'ImageMessage',
  '2': [
    {
      '1': 'timestamp',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
    {'1': 'text', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'text', '17': true},
    {'1': 'media_url', '3': 3, '4': 1, '5': 9, '10': 'mediaUrl'},
    {'1': 'media_type', '3': 4, '4': 1, '5': 9, '10': 'mediaType'},
    {
      '1': 'status',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.yalo.external_channel.in_app.sdk.v2.MessageStatus',
      '10': 'status'
    },
    {
      '1': 'role',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.yalo.external_channel.in_app.sdk.v2.MessageRole',
      '10': 'role'
    },
    {'1': 'byte_count', '3': 7, '4': 1, '5': 3, '10': 'byteCount'},
    {'1': 'file_name', '3': 8, '4': 1, '5': 9, '10': 'fileName'},
  ],
  '8': [
    {'1': '_text'},
  ],
};

/// Descriptor for `ImageMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List imageMessageDescriptor = $convert.base64Decode(
    'CgxJbWFnZU1lc3NhZ2USOAoJdGltZXN0YW1wGAEgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbW'
    'VzdGFtcFIJdGltZXN0YW1wEhcKBHRleHQYAiABKAlIAFIEdGV4dIgBARIbCgltZWRpYV91cmwY'
    'AyABKAlSCG1lZGlhVXJsEh0KCm1lZGlhX3R5cGUYBCABKAlSCW1lZGlhVHlwZRJKCgZzdGF0dX'
    'MYBSABKA4yMi55YWxvLmV4dGVybmFsX2NoYW5uZWwuaW5fYXBwLnNkay52Mi5NZXNzYWdlU3Rh'
    'dHVzUgZzdGF0dXMSRAoEcm9sZRgGIAEoDjIwLnlhbG8uZXh0ZXJuYWxfY2hhbm5lbC5pbl9hcH'
    'Auc2RrLnYyLk1lc3NhZ2VSb2xlUgRyb2xlEh0KCmJ5dGVfY291bnQYByABKANSCWJ5dGVDb3Vu'
    'dBIbCglmaWxlX25hbWUYCCABKAlSCGZpbGVOYW1lQgcKBV90ZXh0');

@$core.Deprecated('Use imageMessageRequestDescriptor instead')
const ImageMessageRequest$json = {
  '1': 'ImageMessageRequest',
  '2': [
    {
      '1': 'content',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v2.ImageMessage',
      '10': 'content'
    },
    {
      '1': 'timestamp',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
    {
      '1': 'buttons',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v2.Button',
      '10': 'buttons'
    },
    {'1': 'header', '3': 4, '4': 1, '5': 9, '9': 0, '10': 'header', '17': true},
    {'1': 'footer', '3': 5, '4': 1, '5': 9, '9': 1, '10': 'footer', '17': true},
  ],
  '8': [
    {'1': '_header'},
    {'1': '_footer'},
  ],
};

/// Descriptor for `ImageMessageRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List imageMessageRequestDescriptor = $convert.base64Decode(
    'ChNJbWFnZU1lc3NhZ2VSZXF1ZXN0EksKB2NvbnRlbnQYASABKAsyMS55YWxvLmV4dGVybmFsX2'
    'NoYW5uZWwuaW5fYXBwLnNkay52Mi5JbWFnZU1lc3NhZ2VSB2NvbnRlbnQSOAoJdGltZXN0YW1w'
    'GAIgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJdGltZXN0YW1wEkUKB2J1dHRvbn'
    'MYAyADKAsyKy55YWxvLmV4dGVybmFsX2NoYW5uZWwuaW5fYXBwLnNkay52Mi5CdXR0b25SB2J1'
    'dHRvbnMSGwoGaGVhZGVyGAQgASgJSABSBmhlYWRlcogBARIbCgZmb290ZXIYBSABKAlIAVIGZm'
    '9vdGVyiAEBQgkKB19oZWFkZXJCCQoHX2Zvb3Rlcg==');

@$core.Deprecated('Use attachmentMessageDescriptor instead')
const AttachmentMessage$json = {
  '1': 'AttachmentMessage',
  '2': [
    {
      '1': 'timestamp',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
    {'1': 'text', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'text', '17': true},
    {'1': 'media_url', '3': 3, '4': 1, '5': 9, '10': 'mediaUrl'},
    {'1': 'media_type', '3': 4, '4': 1, '5': 9, '10': 'mediaType'},
    {
      '1': 'status',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.yalo.external_channel.in_app.sdk.v2.MessageStatus',
      '10': 'status'
    },
    {
      '1': 'role',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.yalo.external_channel.in_app.sdk.v2.MessageRole',
      '10': 'role'
    },
    {'1': 'byte_count', '3': 7, '4': 1, '5': 3, '10': 'byteCount'},
    {'1': 'file_name', '3': 8, '4': 1, '5': 9, '10': 'fileName'},
  ],
  '8': [
    {'1': '_text'},
  ],
};

/// Descriptor for `AttachmentMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List attachmentMessageDescriptor = $convert.base64Decode(
    'ChFBdHRhY2htZW50TWVzc2FnZRI4Cgl0aW1lc3RhbXAYASABKAsyGi5nb29nbGUucHJvdG9idW'
    'YuVGltZXN0YW1wUgl0aW1lc3RhbXASFwoEdGV4dBgCIAEoCUgAUgR0ZXh0iAEBEhsKCW1lZGlh'
    'X3VybBgDIAEoCVIIbWVkaWFVcmwSHQoKbWVkaWFfdHlwZRgEIAEoCVIJbWVkaWFUeXBlEkoKBn'
    'N0YXR1cxgFIAEoDjIyLnlhbG8uZXh0ZXJuYWxfY2hhbm5lbC5pbl9hcHAuc2RrLnYyLk1lc3Nh'
    'Z2VTdGF0dXNSBnN0YXR1cxJECgRyb2xlGAYgASgOMjAueWFsby5leHRlcm5hbF9jaGFubmVsLm'
    'luX2FwcC5zZGsudjIuTWVzc2FnZVJvbGVSBHJvbGUSHQoKYnl0ZV9jb3VudBgHIAEoA1IJYnl0'
    'ZUNvdW50EhsKCWZpbGVfbmFtZRgIIAEoCVIIZmlsZU5hbWVCBwoFX3RleHQ=');

@$core.Deprecated('Use attachmentMessageRequestDescriptor instead')
const AttachmentMessageRequest$json = {
  '1': 'AttachmentMessageRequest',
  '2': [
    {
      '1': 'content',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v2.AttachmentMessage',
      '10': 'content'
    },
    {
      '1': 'timestamp',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
    {
      '1': 'buttons',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v2.Button',
      '10': 'buttons'
    },
    {'1': 'header', '3': 4, '4': 1, '5': 9, '9': 0, '10': 'header', '17': true},
    {'1': 'footer', '3': 5, '4': 1, '5': 9, '9': 1, '10': 'footer', '17': true},
  ],
  '8': [
    {'1': '_header'},
    {'1': '_footer'},
  ],
};

/// Descriptor for `AttachmentMessageRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List attachmentMessageRequestDescriptor = $convert.base64Decode(
    'ChhBdHRhY2htZW50TWVzc2FnZVJlcXVlc3QSUAoHY29udGVudBgBIAEoCzI2LnlhbG8uZXh0ZX'
    'JuYWxfY2hhbm5lbC5pbl9hcHAuc2RrLnYyLkF0dGFjaG1lbnRNZXNzYWdlUgdjb250ZW50EjgK'
    'CXRpbWVzdGFtcBgCIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCXRpbWVzdGFtcB'
    'JFCgdidXR0b25zGAMgAygLMisueWFsby5leHRlcm5hbF9jaGFubmVsLmluX2FwcC5zZGsudjIu'
    'QnV0dG9uUgdidXR0b25zEhsKBmhlYWRlchgEIAEoCUgAUgZoZWFkZXKIAQESGwoGZm9vdGVyGA'
    'UgASgJSAFSBmZvb3RlcogBAUIJCgdfaGVhZGVyQgkKB19mb290ZXI=');

@$core.Deprecated('Use videoMessageDescriptor instead')
const VideoMessage$json = {
  '1': 'VideoMessage',
  '2': [
    {
      '1': 'timestamp',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
    {'1': 'text', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'text', '17': true},
    {'1': 'media_url', '3': 3, '4': 1, '5': 9, '10': 'mediaUrl'},
    {'1': 'media_type', '3': 4, '4': 1, '5': 9, '10': 'mediaType'},
    {
      '1': 'status',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.yalo.external_channel.in_app.sdk.v2.MessageStatus',
      '10': 'status'
    },
    {
      '1': 'role',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.yalo.external_channel.in_app.sdk.v2.MessageRole',
      '10': 'role'
    },
    {'1': 'byte_count', '3': 7, '4': 1, '5': 3, '10': 'byteCount'},
    {'1': 'file_name', '3': 8, '4': 1, '5': 9, '10': 'fileName'},
    {'1': 'duration', '3': 9, '4': 1, '5': 1, '10': 'duration'},
  ],
  '8': [
    {'1': '_text'},
  ],
};

/// Descriptor for `VideoMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List videoMessageDescriptor = $convert.base64Decode(
    'CgxWaWRlb01lc3NhZ2USOAoJdGltZXN0YW1wGAEgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbW'
    'VzdGFtcFIJdGltZXN0YW1wEhcKBHRleHQYAiABKAlIAFIEdGV4dIgBARIbCgltZWRpYV91cmwY'
    'AyABKAlSCG1lZGlhVXJsEh0KCm1lZGlhX3R5cGUYBCABKAlSCW1lZGlhVHlwZRJKCgZzdGF0dX'
    'MYBSABKA4yMi55YWxvLmV4dGVybmFsX2NoYW5uZWwuaW5fYXBwLnNkay52Mi5NZXNzYWdlU3Rh'
    'dHVzUgZzdGF0dXMSRAoEcm9sZRgGIAEoDjIwLnlhbG8uZXh0ZXJuYWxfY2hhbm5lbC5pbl9hcH'
    'Auc2RrLnYyLk1lc3NhZ2VSb2xlUgRyb2xlEh0KCmJ5dGVfY291bnQYByABKANSCWJ5dGVDb3Vu'
    'dBIbCglmaWxlX25hbWUYCCABKAlSCGZpbGVOYW1lEhoKCGR1cmF0aW9uGAkgASgBUghkdXJhdG'
    'lvbkIHCgVfdGV4dA==');

@$core.Deprecated('Use videoMessageRequestDescriptor instead')
const VideoMessageRequest$json = {
  '1': 'VideoMessageRequest',
  '2': [
    {
      '1': 'content',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v2.VideoMessage',
      '10': 'content'
    },
    {
      '1': 'timestamp',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
    {
      '1': 'buttons',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v2.Button',
      '10': 'buttons'
    },
    {'1': 'header', '3': 4, '4': 1, '5': 9, '9': 0, '10': 'header', '17': true},
    {'1': 'footer', '3': 5, '4': 1, '5': 9, '9': 1, '10': 'footer', '17': true},
  ],
  '8': [
    {'1': '_header'},
    {'1': '_footer'},
  ],
};

/// Descriptor for `VideoMessageRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List videoMessageRequestDescriptor = $convert.base64Decode(
    'ChNWaWRlb01lc3NhZ2VSZXF1ZXN0EksKB2NvbnRlbnQYASABKAsyMS55YWxvLmV4dGVybmFsX2'
    'NoYW5uZWwuaW5fYXBwLnNkay52Mi5WaWRlb01lc3NhZ2VSB2NvbnRlbnQSOAoJdGltZXN0YW1w'
    'GAIgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJdGltZXN0YW1wEkUKB2J1dHRvbn'
    'MYAyADKAsyKy55YWxvLmV4dGVybmFsX2NoYW5uZWwuaW5fYXBwLnNkay52Mi5CdXR0b25SB2J1'
    'dHRvbnMSGwoGaGVhZGVyGAQgASgJSABSBmhlYWRlcogBARIbCgZmb290ZXIYBSABKAlIAVIGZm'
    '9vdGVyiAEBQgkKB19oZWFkZXJCCQoHX2Zvb3Rlcg==');

@$core.Deprecated('Use messageReceiptRequestDescriptor instead')
const MessageReceiptRequest$json = {
  '1': 'MessageReceiptRequest',
  '2': [
    {
      '1': 'status',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.yalo.external_channel.in_app.sdk.v2.MessageStatus',
      '10': 'status'
    },
    {'1': 'message_id', '3': 2, '4': 1, '5': 9, '10': 'messageId'},
    {
      '1': 'timestamp',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
  ],
};

/// Descriptor for `MessageReceiptRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageReceiptRequestDescriptor = $convert.base64Decode(
    'ChVNZXNzYWdlUmVjZWlwdFJlcXVlc3QSSgoGc3RhdHVzGAEgASgOMjIueWFsby5leHRlcm5hbF'
    '9jaGFubmVsLmluX2FwcC5zZGsudjIuTWVzc2FnZVN0YXR1c1IGc3RhdHVzEh0KCm1lc3NhZ2Vf'
    'aWQYAiABKAlSCW1lc3NhZ2VJZBI4Cgl0aW1lc3RhbXAYAyABKAsyGi5nb29nbGUucHJvdG9idW'
    'YuVGltZXN0YW1wUgl0aW1lc3RhbXA=');

@$core.Deprecated('Use addToCartRequestDescriptor instead')
const AddToCartRequest$json = {
  '1': 'AddToCartRequest',
  '2': [
    {'1': 'sku', '3': 1, '4': 1, '5': 9, '10': 'sku'},
    {
      '1': 'timestamp',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
    {'1': 'quantity', '3': 3, '4': 1, '5': 1, '10': 'quantity'},
    {
      '1': 'unit_type',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.yalo.external_channel.in_app.sdk.v2.UnitType',
      '10': 'unitType'
    },
  ],
};

/// Descriptor for `AddToCartRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addToCartRequestDescriptor = $convert.base64Decode(
    'ChBBZGRUb0NhcnRSZXF1ZXN0EhAKA3NrdRgBIAEoCVIDc2t1EjgKCXRpbWVzdGFtcBgCIAEoCz'
    'IaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCXRpbWVzdGFtcBIaCghxdWFudGl0eRgDIAEo'
    'AVIIcXVhbnRpdHkSSgoJdW5pdF90eXBlGAQgASgOMi0ueWFsby5leHRlcm5hbF9jaGFubmVsLm'
    'luX2FwcC5zZGsudjIuVW5pdFR5cGVSCHVuaXRUeXBl');

@$core.Deprecated('Use addToCartResponseDescriptor instead')
const AddToCartResponse$json = {
  '1': 'AddToCartResponse',
  '2': [
    {
      '1': 'status',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.yalo.external_channel.in_app.sdk.v2.ResponseStatus',
      '10': 'status'
    },
    {
      '1': 'timestamp',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
  ],
};

/// Descriptor for `AddToCartResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addToCartResponseDescriptor = $convert.base64Decode(
    'ChFBZGRUb0NhcnRSZXNwb25zZRJLCgZzdGF0dXMYASABKA4yMy55YWxvLmV4dGVybmFsX2NoYW'
    '5uZWwuaW5fYXBwLnNkay52Mi5SZXNwb25zZVN0YXR1c1IGc3RhdHVzEjgKCXRpbWVzdGFtcBgC'
    'IAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCXRpbWVzdGFtcA==');

@$core.Deprecated('Use removeFromCartRequestDescriptor instead')
const RemoveFromCartRequest$json = {
  '1': 'RemoveFromCartRequest',
  '2': [
    {'1': 'sku', '3': 1, '4': 1, '5': 9, '10': 'sku'},
    {
      '1': 'timestamp',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
    {
      '1': 'quantity',
      '3': 3,
      '4': 1,
      '5': 1,
      '9': 0,
      '10': 'quantity',
      '17': true
    },
    {
      '1': 'unit_type',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.yalo.external_channel.in_app.sdk.v2.UnitType',
      '10': 'unitType'
    },
  ],
  '8': [
    {'1': '_quantity'},
  ],
};

/// Descriptor for `RemoveFromCartRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List removeFromCartRequestDescriptor = $convert.base64Decode(
    'ChVSZW1vdmVGcm9tQ2FydFJlcXVlc3QSEAoDc2t1GAEgASgJUgNza3USOAoJdGltZXN0YW1wGA'
    'IgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJdGltZXN0YW1wEh8KCHF1YW50aXR5'
    'GAMgASgBSABSCHF1YW50aXR5iAEBEkoKCXVuaXRfdHlwZRgEIAEoDjItLnlhbG8uZXh0ZXJuYW'
    'xfY2hhbm5lbC5pbl9hcHAuc2RrLnYyLlVuaXRUeXBlUgh1bml0VHlwZUILCglfcXVhbnRpdHk=');

@$core.Deprecated('Use removeFromCartResponseDescriptor instead')
const RemoveFromCartResponse$json = {
  '1': 'RemoveFromCartResponse',
  '2': [
    {
      '1': 'status',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.yalo.external_channel.in_app.sdk.v2.ResponseStatus',
      '10': 'status'
    },
    {
      '1': 'timestamp',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
  ],
};

/// Descriptor for `RemoveFromCartResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List removeFromCartResponseDescriptor = $convert.base64Decode(
    'ChZSZW1vdmVGcm9tQ2FydFJlc3BvbnNlEksKBnN0YXR1cxgBIAEoDjIzLnlhbG8uZXh0ZXJuYW'
    'xfY2hhbm5lbC5pbl9hcHAuc2RrLnYyLlJlc3BvbnNlU3RhdHVzUgZzdGF0dXMSOAoJdGltZXN0'
    'YW1wGAIgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJdGltZXN0YW1w');

@$core.Deprecated('Use clearCartRequestDescriptor instead')
const ClearCartRequest$json = {
  '1': 'ClearCartRequest',
  '2': [
    {
      '1': 'timestamp',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
  ],
};

/// Descriptor for `ClearCartRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clearCartRequestDescriptor = $convert.base64Decode(
    'ChBDbGVhckNhcnRSZXF1ZXN0EjgKCXRpbWVzdGFtcBgBIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi'
    '5UaW1lc3RhbXBSCXRpbWVzdGFtcA==');

@$core.Deprecated('Use clearCartResponseDescriptor instead')
const ClearCartResponse$json = {
  '1': 'ClearCartResponse',
  '2': [
    {
      '1': 'status',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.yalo.external_channel.in_app.sdk.v2.ResponseStatus',
      '10': 'status'
    },
    {
      '1': 'timestamp',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
  ],
};

/// Descriptor for `ClearCartResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clearCartResponseDescriptor = $convert.base64Decode(
    'ChFDbGVhckNhcnRSZXNwb25zZRJLCgZzdGF0dXMYASABKA4yMy55YWxvLmV4dGVybmFsX2NoYW'
    '5uZWwuaW5fYXBwLnNkay52Mi5SZXNwb25zZVN0YXR1c1IGc3RhdHVzEjgKCXRpbWVzdGFtcBgC'
    'IAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCXRpbWVzdGFtcA==');

@$core.Deprecated('Use guidanceCardRequestDescriptor instead')
const GuidanceCardRequest$json = {
  '1': 'GuidanceCardRequest',
  '2': [
    {
      '1': 'timestamp',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
    {
      '1': 'target_id',
      '3': 2,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'targetId',
      '17': true
    },
    {
      '1': 'context',
      '3': 3,
      '4': 1,
      '5': 9,
      '9': 1,
      '10': 'context',
      '17': true
    },
  ],
  '8': [
    {'1': '_target_id'},
    {'1': '_context'},
  ],
};

/// Descriptor for `GuidanceCardRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List guidanceCardRequestDescriptor = $convert.base64Decode(
    'ChNHdWlkYW5jZUNhcmRSZXF1ZXN0EjgKCXRpbWVzdGFtcBgBIAEoCzIaLmdvb2dsZS5wcm90b2'
    'J1Zi5UaW1lc3RhbXBSCXRpbWVzdGFtcBIgCgl0YXJnZXRfaWQYAiABKAlIAFIIdGFyZ2V0SWSI'
    'AQESHQoHY29udGV4dBgDIAEoCUgBUgdjb250ZXh0iAEBQgwKCl90YXJnZXRfaWRCCgoIX2Nvbn'
    'RleHQ=');

@$core.Deprecated('Use guidanceCardResponseDescriptor instead')
const GuidanceCardResponse$json = {
  '1': 'GuidanceCardResponse',
  '2': [
    {
      '1': 'status',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.yalo.external_channel.in_app.sdk.v2.ResponseStatus',
      '10': 'status'
    },
    {
      '1': 'timestamp',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
    {'1': 'guidance_title', '3': 3, '4': 1, '5': 9, '10': 'guidanceTitle'},
    {
      '1': 'guidance_description',
      '3': 4,
      '4': 1,
      '5': 9,
      '10': 'guidanceDescription'
    },
    {'1': 'guidance_cards', '3': 5, '4': 3, '5': 9, '10': 'guidanceCards'},
  ],
};

/// Descriptor for `GuidanceCardResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List guidanceCardResponseDescriptor = $convert.base64Decode(
    'ChRHdWlkYW5jZUNhcmRSZXNwb25zZRJLCgZzdGF0dXMYASABKA4yMy55YWxvLmV4dGVybmFsX2'
    'NoYW5uZWwuaW5fYXBwLnNkay52Mi5SZXNwb25zZVN0YXR1c1IGc3RhdHVzEjgKCXRpbWVzdGFt'
    'cBgCIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCXRpbWVzdGFtcBIlCg5ndWlkYW'
    '5jZV90aXRsZRgDIAEoCVINZ3VpZGFuY2VUaXRsZRIxChRndWlkYW5jZV9kZXNjcmlwdGlvbhgE'
    'IAEoCVITZ3VpZGFuY2VEZXNjcmlwdGlvbhIlCg5ndWlkYW5jZV9jYXJkcxgFIAMoCVINZ3VpZG'
    'FuY2VDYXJkcw==');

@$core.Deprecated('Use addPromotionRequestDescriptor instead')
const AddPromotionRequest$json = {
  '1': 'AddPromotionRequest',
  '2': [
    {'1': 'promotion_id', '3': 1, '4': 1, '5': 9, '10': 'promotionId'},
    {
      '1': 'timestamp',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
  ],
};

/// Descriptor for `AddPromotionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addPromotionRequestDescriptor = $convert.base64Decode(
    'ChNBZGRQcm9tb3Rpb25SZXF1ZXN0EiEKDHByb21vdGlvbl9pZBgBIAEoCVILcHJvbW90aW9uSW'
    'QSOAoJdGltZXN0YW1wGAIgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJdGltZXN0'
    'YW1w');

@$core.Deprecated('Use addPromotionResponseDescriptor instead')
const AddPromotionResponse$json = {
  '1': 'AddPromotionResponse',
  '2': [
    {
      '1': 'status',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.yalo.external_channel.in_app.sdk.v2.ResponseStatus',
      '10': 'status'
    },
    {
      '1': 'timestamp',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
  ],
};

/// Descriptor for `AddPromotionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addPromotionResponseDescriptor = $convert.base64Decode(
    'ChRBZGRQcm9tb3Rpb25SZXNwb25zZRJLCgZzdGF0dXMYASABKA4yMy55YWxvLmV4dGVybmFsX2'
    'NoYW5uZWwuaW5fYXBwLnNkay52Mi5SZXNwb25zZVN0YXR1c1IGc3RhdHVzEjgKCXRpbWVzdGFt'
    'cBgCIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCXRpbWVzdGFtcA==');

@$core.Deprecated('Use promotionMessageRequestDescriptor instead')
const PromotionMessageRequest$json = {
  '1': 'PromotionMessageRequest',
  '2': [
    {'1': 'promotion_id', '3': 1, '4': 1, '5': 9, '10': 'promotionId'},
    {'1': 'title', '3': 2, '4': 1, '5': 9, '10': 'title'},
    {'1': 'gain', '3': 3, '4': 1, '5': 9, '10': 'gain'},
    {'1': 'description', '3': 4, '4': 1, '5': 9, '10': 'description'},
    {'1': 'image_url', '3': 5, '4': 1, '5': 9, '10': 'imageUrl'},
    {'1': 'footer', '3': 6, '4': 1, '5': 9, '10': 'footer'},
    {
      '1': 'timestamp',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
  ],
};

/// Descriptor for `PromotionMessageRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List promotionMessageRequestDescriptor = $convert.base64Decode(
    'ChdQcm9tb3Rpb25NZXNzYWdlUmVxdWVzdBIhCgxwcm9tb3Rpb25faWQYASABKAlSC3Byb21vdG'
    'lvbklkEhQKBXRpdGxlGAIgASgJUgV0aXRsZRISCgRnYWluGAMgASgJUgRnYWluEiAKC2Rlc2Ny'
    'aXB0aW9uGAQgASgJUgtkZXNjcmlwdGlvbhIbCglpbWFnZV91cmwYBSABKAlSCGltYWdlVXJsEh'
    'YKBmZvb3RlchgGIAEoCVIGZm9vdGVyEjgKCXRpbWVzdGFtcBgHIAEoCzIaLmdvb2dsZS5wcm90'
    'b2J1Zi5UaW1lc3RhbXBSCXRpbWVzdGFtcA==');

@$core.Deprecated('Use promotionMessageResponseDescriptor instead')
const PromotionMessageResponse$json = {
  '1': 'PromotionMessageResponse',
  '2': [
    {
      '1': 'status',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.yalo.external_channel.in_app.sdk.v2.ResponseStatus',
      '10': 'status'
    },
    {
      '1': 'timestamp',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
  ],
};

/// Descriptor for `PromotionMessageResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List promotionMessageResponseDescriptor = $convert.base64Decode(
    'ChhQcm9tb3Rpb25NZXNzYWdlUmVzcG9uc2USSwoGc3RhdHVzGAEgASgOMjMueWFsby5leHRlcm'
    '5hbF9jaGFubmVsLmluX2FwcC5zZGsudjIuUmVzcG9uc2VTdGF0dXNSBnN0YXR1cxI4Cgl0aW1l'
    'c3RhbXAYAiABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgl0aW1lc3RhbXA=');

@$core.Deprecated('Use productDescriptor instead')
const Product$json = {
  '1': 'Product',
  '2': [
    {'1': 'sku', '3': 1, '4': 1, '5': 9, '10': 'sku'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'price', '3': 3, '4': 1, '5': 1, '10': 'price'},
    {'1': 'images_url', '3': 4, '4': 3, '5': 9, '10': 'imagesUrl'},
    {
      '1': 'sale_price',
      '3': 5,
      '4': 1,
      '5': 1,
      '9': 0,
      '10': 'salePrice',
      '17': true
    },
    {'1': 'subunits', '3': 6, '4': 1, '5': 1, '10': 'subunits'},
    {'1': 'unit_step', '3': 7, '4': 1, '5': 1, '10': 'unitStep'},
    {'1': 'unit_name', '3': 8, '4': 1, '5': 9, '10': 'unitName'},
    {
      '1': 'subunit_name',
      '3': 9,
      '4': 1,
      '5': 9,
      '9': 1,
      '10': 'subunitName',
      '17': true
    },
    {'1': 'subunit_step', '3': 10, '4': 1, '5': 1, '10': 'subunitStep'},
    {'1': 'units_added', '3': 11, '4': 1, '5': 1, '10': 'unitsAdded'},
    {'1': 'subunits_added', '3': 12, '4': 1, '5': 1, '10': 'subunitsAdded'},
  ],
  '8': [
    {'1': '_sale_price'},
    {'1': '_subunit_name'},
  ],
};

/// Descriptor for `Product`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List productDescriptor = $convert.base64Decode(
    'CgdQcm9kdWN0EhAKA3NrdRgBIAEoCVIDc2t1EhIKBG5hbWUYAiABKAlSBG5hbWUSFAoFcHJpY2'
    'UYAyABKAFSBXByaWNlEh0KCmltYWdlc191cmwYBCADKAlSCWltYWdlc1VybBIiCgpzYWxlX3By'
    'aWNlGAUgASgBSABSCXNhbGVQcmljZYgBARIaCghzdWJ1bml0cxgGIAEoAVIIc3VidW5pdHMSGw'
    'oJdW5pdF9zdGVwGAcgASgBUgh1bml0U3RlcBIbCgl1bml0X25hbWUYCCABKAlSCHVuaXROYW1l'
    'EiYKDHN1YnVuaXRfbmFtZRgJIAEoCUgBUgtzdWJ1bml0TmFtZYgBARIhCgxzdWJ1bml0X3N0ZX'
    'AYCiABKAFSC3N1YnVuaXRTdGVwEh8KC3VuaXRzX2FkZGVkGAsgASgBUgp1bml0c0FkZGVkEiUK'
    'DnN1YnVuaXRzX2FkZGVkGAwgASgBUg1zdWJ1bml0c0FkZGVkQg0KC19zYWxlX3ByaWNlQg8KDV'
    '9zdWJ1bml0X25hbWU=');

@$core.Deprecated('Use productMessageRequestDescriptor instead')
const ProductMessageRequest$json = {
  '1': 'ProductMessageRequest',
  '2': [
    {
      '1': 'products',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v2.Product',
      '10': 'products'
    },
    {
      '1': 'orientation',
      '3': 2,
      '4': 1,
      '5': 14,
      '6':
          '.yalo.external_channel.in_app.sdk.v2.ProductMessageRequest.Orientation',
      '10': 'orientation'
    },
    {
      '1': 'timestamp',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
  ],
  '4': [ProductMessageRequest_Orientation$json],
};

@$core.Deprecated('Use productMessageRequestDescriptor instead')
const ProductMessageRequest_Orientation$json = {
  '1': 'Orientation',
  '2': [
    {'1': 'ORIENTATION_UNSPECIFIED', '2': 0},
    {'1': 'ORIENTATION_VERTICAL', '2': 1},
    {'1': 'ORIENTATION_HORIZONTAL', '2': 2},
  ],
};

/// Descriptor for `ProductMessageRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List productMessageRequestDescriptor = $convert.base64Decode(
    'ChVQcm9kdWN0TWVzc2FnZVJlcXVlc3QSSAoIcHJvZHVjdHMYASADKAsyLC55YWxvLmV4dGVybm'
    'FsX2NoYW5uZWwuaW5fYXBwLnNkay52Mi5Qcm9kdWN0Ughwcm9kdWN0cxJoCgtvcmllbnRhdGlv'
    'bhgCIAEoDjJGLnlhbG8uZXh0ZXJuYWxfY2hhbm5lbC5pbl9hcHAuc2RrLnYyLlByb2R1Y3RNZX'
    'NzYWdlUmVxdWVzdC5PcmllbnRhdGlvblILb3JpZW50YXRpb24SOAoJdGltZXN0YW1wGAMgASgL'
    'MhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJdGltZXN0YW1wImAKC09yaWVudGF0aW9uEh'
    'sKF09SSUVOVEFUSU9OX1VOU1BFQ0lGSUVEEAASGAoUT1JJRU5UQVRJT05fVkVSVElDQUwQARIa'
    'ChZPUklFTlRBVElPTl9IT1JJWk9OVEFMEAI=');

@$core.Deprecated('Use productMessageResponseDescriptor instead')
const ProductMessageResponse$json = {
  '1': 'ProductMessageResponse',
  '2': [
    {
      '1': 'status',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.yalo.external_channel.in_app.sdk.v2.ResponseStatus',
      '10': 'status'
    },
    {
      '1': 'timestamp',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
  ],
};

/// Descriptor for `ProductMessageResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List productMessageResponseDescriptor = $convert.base64Decode(
    'ChZQcm9kdWN0TWVzc2FnZVJlc3BvbnNlEksKBnN0YXR1cxgBIAEoDjIzLnlhbG8uZXh0ZXJuYW'
    'xfY2hhbm5lbC5pbl9hcHAuc2RrLnYyLlJlc3BvbnNlU3RhdHVzUgZzdGF0dXMSOAoJdGltZXN0'
    'YW1wGAIgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJdGltZXN0YW1w');

@$core.Deprecated('Use chatStatusRequestDescriptor instead')
const ChatStatusRequest$json = {
  '1': 'ChatStatusRequest',
  '2': [
    {'1': 'status', '3': 1, '4': 1, '5': 9, '10': 'status'},
    {
      '1': 'timestamp',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
  ],
};

/// Descriptor for `ChatStatusRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatStatusRequestDescriptor = $convert.base64Decode(
    'ChFDaGF0U3RhdHVzUmVxdWVzdBIWCgZzdGF0dXMYASABKAlSBnN0YXR1cxI4Cgl0aW1lc3RhbX'
    'AYAiABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgl0aW1lc3RhbXA=');

@$core.Deprecated('Use chatStatusResponseDescriptor instead')
const ChatStatusResponse$json = {
  '1': 'ChatStatusResponse',
  '2': [
    {
      '1': 'status',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.yalo.external_channel.in_app.sdk.v2.ResponseStatus',
      '10': 'status'
    },
    {
      '1': 'timestamp',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
  ],
};

/// Descriptor for `ChatStatusResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatStatusResponseDescriptor = $convert.base64Decode(
    'ChJDaGF0U3RhdHVzUmVzcG9uc2USSwoGc3RhdHVzGAEgASgOMjMueWFsby5leHRlcm5hbF9jaG'
    'FubmVsLmluX2FwcC5zZGsudjIuUmVzcG9uc2VTdGF0dXNSBnN0YXR1cxI4Cgl0aW1lc3RhbXAY'
    'AiABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgl0aW1lc3RhbXA=');

@$core.Deprecated('Use customCommandRequestDescriptor instead')
const CustomCommandRequest$json = {
  '1': 'CustomCommandRequest',
  '2': [
    {'1': 'command_id', '3': 1, '4': 1, '5': 9, '10': 'commandId'},
    {'1': 'payload', '3': 2, '4': 1, '5': 9, '10': 'payload'},
    {
      '1': 'timestamp',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
  ],
};

/// Descriptor for `CustomCommandRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List customCommandRequestDescriptor = $convert.base64Decode(
    'ChRDdXN0b21Db21tYW5kUmVxdWVzdBIdCgpjb21tYW5kX2lkGAEgASgJUgljb21tYW5kSWQSGA'
    'oHcGF5bG9hZBgCIAEoCVIHcGF5bG9hZBI4Cgl0aW1lc3RhbXAYAyABKAsyGi5nb29nbGUucHJv'
    'dG9idWYuVGltZXN0YW1wUgl0aW1lc3RhbXA=');

@$core.Deprecated('Use customCommandResponseDescriptor instead')
const CustomCommandResponse$json = {
  '1': 'CustomCommandResponse',
  '2': [
    {
      '1': 'status',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.yalo.external_channel.in_app.sdk.v2.ResponseStatus',
      '10': 'status'
    },
    {'1': 'payload', '3': 2, '4': 1, '5': 9, '10': 'payload'},
    {
      '1': 'timestamp',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
  ],
};

/// Descriptor for `CustomCommandResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List customCommandResponseDescriptor = $convert.base64Decode(
    'ChVDdXN0b21Db21tYW5kUmVzcG9uc2USSwoGc3RhdHVzGAEgASgOMjMueWFsby5leHRlcm5hbF'
    '9jaGFubmVsLmluX2FwcC5zZGsudjIuUmVzcG9uc2VTdGF0dXNSBnN0YXR1cxIYCgdwYXlsb2Fk'
    'GAIgASgJUgdwYXlsb2FkEjgKCXRpbWVzdGFtcBgDIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW'
    '1lc3RhbXBSCXRpbWVzdGFtcA==');

@$core.Deprecated('Use getCommandsRequestDescriptor instead')
const GetCommandsRequest$json = {
  '1': 'GetCommandsRequest',
  '2': [
    {
      '1': 'timestamp',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
  ],
};

/// Descriptor for `GetCommandsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getCommandsRequestDescriptor = $convert.base64Decode(
    'ChJHZXRDb21tYW5kc1JlcXVlc3QSOAoJdGltZXN0YW1wGAEgASgLMhouZ29vZ2xlLnByb3RvYn'
    'VmLlRpbWVzdGFtcFIJdGltZXN0YW1w');

@$core.Deprecated('Use getCommandsResponseDescriptor instead')
const GetCommandsResponse$json = {
  '1': 'GetCommandsResponse',
  '2': [
    {
      '1': 'commands',
      '3': 1,
      '4': 3,
      '5': 14,
      '6': '.yalo.external_channel.in_app.sdk.v2.SdkCommand',
      '10': 'commands'
    },
    {
      '1': 'timestamp',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
  ],
};

/// Descriptor for `GetCommandsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getCommandsResponseDescriptor = $convert.base64Decode(
    'ChNHZXRDb21tYW5kc1Jlc3BvbnNlEksKCGNvbW1hbmRzGAEgAygOMi8ueWFsby5leHRlcm5hbF'
    '9jaGFubmVsLmluX2FwcC5zZGsudjIuU2RrQ29tbWFuZFIIY29tbWFuZHMSOAoJdGltZXN0YW1w'
    'GAIgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJdGltZXN0YW1w');

@$core.Deprecated('Use authRequestDescriptor instead')
const AuthRequest$json = {
  '1': 'AuthRequest',
  '2': [
    {'1': 'user_type', '3': 1, '4': 1, '5': 9, '10': 'userType'},
    {'1': 'channel_id', '3': 2, '4': 1, '5': 9, '10': 'channelId'},
    {'1': 'organization_id', '3': 3, '4': 1, '5': 9, '10': 'organizationId'},
    {'1': 'timestamp', '3': 4, '4': 1, '5': 3, '10': 'timestamp'},
  ],
};

/// Descriptor for `AuthRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List authRequestDescriptor = $convert.base64Decode(
    'CgtBdXRoUmVxdWVzdBIbCgl1c2VyX3R5cGUYASABKAlSCHVzZXJUeXBlEh0KCmNoYW5uZWxfaW'
    'QYAiABKAlSCWNoYW5uZWxJZBInCg9vcmdhbml6YXRpb25faWQYAyABKAlSDm9yZ2FuaXphdGlv'
    'bklkEhwKCXRpbWVzdGFtcBgEIAEoA1IJdGltZXN0YW1w');

@$core.Deprecated('Use refreshTokenRequestDescriptor instead')
const RefreshTokenRequest$json = {
  '1': 'RefreshTokenRequest',
  '2': [
    {'1': 'grant_type', '3': 1, '4': 1, '5': 9, '10': 'grantType'},
    {'1': 'refresh_token', '3': 2, '4': 1, '5': 9, '10': 'refreshToken'},
  ],
};

/// Descriptor for `RefreshTokenRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List refreshTokenRequestDescriptor = $convert.base64Decode(
    'ChNSZWZyZXNoVG9rZW5SZXF1ZXN0Eh0KCmdyYW50X3R5cGUYASABKAlSCWdyYW50VHlwZRIjCg'
    '1yZWZyZXNoX3Rva2VuGAIgASgJUgxyZWZyZXNoVG9rZW4=');

@$core.Deprecated('Use authResponseDescriptor instead')
const AuthResponse$json = {
  '1': 'AuthResponse',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'token_type', '3': 2, '4': 1, '5': 9, '10': 'tokenType'},
    {'1': 'expires_in', '3': 3, '4': 1, '5': 3, '10': 'expiresIn'},
    {'1': 'refresh_token', '3': 4, '4': 1, '5': 9, '10': 'refreshToken'},
    {'1': 'client_id', '3': 5, '4': 1, '5': 9, '10': 'clientId'},
  ],
};

/// Descriptor for `AuthResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List authResponseDescriptor = $convert.base64Decode(
    'CgxBdXRoUmVzcG9uc2USIQoMYWNjZXNzX3Rva2VuGAEgASgJUgthY2Nlc3NUb2tlbhIdCgp0b2'
    'tlbl90eXBlGAIgASgJUgl0b2tlblR5cGUSHQoKZXhwaXJlc19pbhgDIAEoA1IJZXhwaXJlc0lu'
    'EiMKDXJlZnJlc2hfdG9rZW4YBCABKAlSDHJlZnJlc2hUb2tlbhIbCgljbGllbnRfaWQYBSABKA'
    'lSCGNsaWVudElk');

@$core.Deprecated('Use pollMessageItemDescriptor instead')
const PollMessageItem$json = {
  '1': 'PollMessageItem',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'message',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v2.SdkMessage',
      '10': 'message'
    },
    {
      '1': 'date',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'date'
    },
    {'1': 'user_id', '3': 4, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'status', '3': 5, '4': 1, '5': 9, '10': 'status'},
  ],
};

/// Descriptor for `PollMessageItem`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pollMessageItemDescriptor = $convert.base64Decode(
    'Cg9Qb2xsTWVzc2FnZUl0ZW0SDgoCaWQYASABKAlSAmlkEkkKB21lc3NhZ2UYAiABKAsyLy55YW'
    'xvLmV4dGVybmFsX2NoYW5uZWwuaW5fYXBwLnNkay52Mi5TZGtNZXNzYWdlUgdtZXNzYWdlEi4K'
    'BGRhdGUYAyABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgRkYXRlEhcKB3VzZXJfaW'
    'QYBCABKAlSBnVzZXJJZBIWCgZzdGF0dXMYBSABKAlSBnN0YXR1cw==');
