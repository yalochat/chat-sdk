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
      '6': '.yalo.external_channel.in_app.sdk.v1.TextMessageRequest',
      '9': 0,
      '10': 'textMessageRequest'
    },
    {
      '1': 'text_message_response',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v1.TextMessageResponse',
      '9': 0,
      '10': 'textMessageResponse'
    },
    {
      '1': 'voice_message_request',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v1.VoiceMessageRequest',
      '9': 0,
      '10': 'voiceMessageRequest'
    },
    {
      '1': 'voice_message_response',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v1.VoiceMessageResponse',
      '9': 0,
      '10': 'voiceMessageResponse'
    },
    {
      '1': 'image_message_request',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v1.ImageMessageRequest',
      '9': 0,
      '10': 'imageMessageRequest'
    },
    {
      '1': 'image_message_response',
      '3': 15,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v1.ImageMessageResponse',
      '9': 0,
      '10': 'imageMessageResponse'
    },
    {
      '1': 'message_receipt_request',
      '3': 16,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v1.MessageReceiptRequest',
      '9': 0,
      '10': 'messageReceiptRequest'
    },
    {
      '1': 'message_receipt_response',
      '3': 17,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v1.MessageReceiptResponse',
      '9': 0,
      '10': 'messageReceiptResponse'
    },
    {
      '1': 'add_to_cart_request',
      '3': 20,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v1.AddToCartRequest',
      '9': 0,
      '10': 'addToCartRequest'
    },
    {
      '1': 'add_to_cart_response',
      '3': 21,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v1.AddToCartResponse',
      '9': 0,
      '10': 'addToCartResponse'
    },
    {
      '1': 'remove_from_cart_request',
      '3': 22,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v1.RemoveFromCartRequest',
      '9': 0,
      '10': 'removeFromCartRequest'
    },
    {
      '1': 'remove_from_cart_response',
      '3': 23,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v1.RemoveFromCartResponse',
      '9': 0,
      '10': 'removeFromCartResponse'
    },
    {
      '1': 'clear_cart_request',
      '3': 24,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v1.ClearCartRequest',
      '9': 0,
      '10': 'clearCartRequest'
    },
    {
      '1': 'clear_cart_response',
      '3': 25,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v1.ClearCartResponse',
      '9': 0,
      '10': 'clearCartResponse'
    },
    {
      '1': 'guidance_card_request',
      '3': 26,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v1.GuidanceCardRequest',
      '9': 0,
      '10': 'guidanceCardRequest'
    },
    {
      '1': 'guidance_card_response',
      '3': 27,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v1.GuidanceCardResponse',
      '9': 0,
      '10': 'guidanceCardResponse'
    },
    {
      '1': 'add_promotion_request',
      '3': 28,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v1.AddPromotionRequest',
      '9': 0,
      '10': 'addPromotionRequest'
    },
    {
      '1': 'add_promotion_response',
      '3': 29,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v1.AddPromotionResponse',
      '9': 0,
      '10': 'addPromotionResponse'
    },
    {
      '1': 'promotion_message_request',
      '3': 30,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v1.PromotionMessageRequest',
      '9': 0,
      '10': 'promotionMessageRequest'
    },
    {
      '1': 'promotion_message_response',
      '3': 31,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v1.PromotionMessageResponse',
      '9': 0,
      '10': 'promotionMessageResponse'
    },
    {
      '1': 'product_message_request',
      '3': 32,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v1.ProductMessageRequest',
      '9': 0,
      '10': 'productMessageRequest'
    },
    {
      '1': 'product_message_response',
      '3': 33,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v1.ProductMessageResponse',
      '9': 0,
      '10': 'productMessageResponse'
    },
    {
      '1': 'chat_status_request',
      '3': 34,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v1.ChatStatusRequest',
      '9': 0,
      '10': 'chatStatusRequest'
    },
    {
      '1': 'chat_status_response',
      '3': 35,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v1.ChatStatusResponse',
      '9': 0,
      '10': 'chatStatusResponse'
    },
    {
      '1': 'custom_action_request',
      '3': 36,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v1.CustomActionRequest',
      '9': 0,
      '10': 'customActionRequest'
    },
    {
      '1': 'custom_action_response',
      '3': 37,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v1.CustomActionResponse',
      '9': 0,
      '10': 'customActionResponse'
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
    '9hcHAuc2RrLnYxLlRleHRNZXNzYWdlUmVxdWVzdEgAUhJ0ZXh0TWVzc2FnZVJlcXVlc3QSbgoV'
    'dGV4dF9tZXNzYWdlX3Jlc3BvbnNlGAsgASgLMjgueWFsby5leHRlcm5hbF9jaGFubmVsLmluX2'
    'FwcC5zZGsudjEuVGV4dE1lc3NhZ2VSZXNwb25zZUgAUhN0ZXh0TWVzc2FnZVJlc3BvbnNlEm4K'
    'FXZvaWNlX21lc3NhZ2VfcmVxdWVzdBgMIAEoCzI4LnlhbG8uZXh0ZXJuYWxfY2hhbm5lbC5pbl'
    '9hcHAuc2RrLnYxLlZvaWNlTWVzc2FnZVJlcXVlc3RIAFITdm9pY2VNZXNzYWdlUmVxdWVzdBJx'
    'ChZ2b2ljZV9tZXNzYWdlX3Jlc3BvbnNlGA0gASgLMjkueWFsby5leHRlcm5hbF9jaGFubmVsLm'
    'luX2FwcC5zZGsudjEuVm9pY2VNZXNzYWdlUmVzcG9uc2VIAFIUdm9pY2VNZXNzYWdlUmVzcG9u'
    'c2USbgoVaW1hZ2VfbWVzc2FnZV9yZXF1ZXN0GA4gASgLMjgueWFsby5leHRlcm5hbF9jaGFubm'
    'VsLmluX2FwcC5zZGsudjEuSW1hZ2VNZXNzYWdlUmVxdWVzdEgAUhNpbWFnZU1lc3NhZ2VSZXF1'
    'ZXN0EnEKFmltYWdlX21lc3NhZ2VfcmVzcG9uc2UYDyABKAsyOS55YWxvLmV4dGVybmFsX2NoYW'
    '5uZWwuaW5fYXBwLnNkay52MS5JbWFnZU1lc3NhZ2VSZXNwb25zZUgAUhRpbWFnZU1lc3NhZ2VS'
    'ZXNwb25zZRJ0ChdtZXNzYWdlX3JlY2VpcHRfcmVxdWVzdBgQIAEoCzI6LnlhbG8uZXh0ZXJuYW'
    'xfY2hhbm5lbC5pbl9hcHAuc2RrLnYxLk1lc3NhZ2VSZWNlaXB0UmVxdWVzdEgAUhVtZXNzYWdl'
    'UmVjZWlwdFJlcXVlc3QSdwoYbWVzc2FnZV9yZWNlaXB0X3Jlc3BvbnNlGBEgASgLMjsueWFsby'
    '5leHRlcm5hbF9jaGFubmVsLmluX2FwcC5zZGsudjEuTWVzc2FnZVJlY2VpcHRSZXNwb25zZUgA'
    'UhZtZXNzYWdlUmVjZWlwdFJlc3BvbnNlEmYKE2FkZF90b19jYXJ0X3JlcXVlc3QYFCABKAsyNS'
    '55YWxvLmV4dGVybmFsX2NoYW5uZWwuaW5fYXBwLnNkay52MS5BZGRUb0NhcnRSZXF1ZXN0SABS'
    'EGFkZFRvQ2FydFJlcXVlc3QSaQoUYWRkX3RvX2NhcnRfcmVzcG9uc2UYFSABKAsyNi55YWxvLm'
    'V4dGVybmFsX2NoYW5uZWwuaW5fYXBwLnNkay52MS5BZGRUb0NhcnRSZXNwb25zZUgAUhFhZGRU'
    'b0NhcnRSZXNwb25zZRJ1ChhyZW1vdmVfZnJvbV9jYXJ0X3JlcXVlc3QYFiABKAsyOi55YWxvLm'
    'V4dGVybmFsX2NoYW5uZWwuaW5fYXBwLnNkay52MS5SZW1vdmVGcm9tQ2FydFJlcXVlc3RIAFIV'
    'cmVtb3ZlRnJvbUNhcnRSZXF1ZXN0EngKGXJlbW92ZV9mcm9tX2NhcnRfcmVzcG9uc2UYFyABKA'
    'syOy55YWxvLmV4dGVybmFsX2NoYW5uZWwuaW5fYXBwLnNkay52MS5SZW1vdmVGcm9tQ2FydFJl'
    'c3BvbnNlSABSFnJlbW92ZUZyb21DYXJ0UmVzcG9uc2USZQoSY2xlYXJfY2FydF9yZXF1ZXN0GB'
    'ggASgLMjUueWFsby5leHRlcm5hbF9jaGFubmVsLmluX2FwcC5zZGsudjEuQ2xlYXJDYXJ0UmVx'
    'dWVzdEgAUhBjbGVhckNhcnRSZXF1ZXN0EmgKE2NsZWFyX2NhcnRfcmVzcG9uc2UYGSABKAsyNi'
    '55YWxvLmV4dGVybmFsX2NoYW5uZWwuaW5fYXBwLnNkay52MS5DbGVhckNhcnRSZXNwb25zZUgA'
    'UhFjbGVhckNhcnRSZXNwb25zZRJuChVndWlkYW5jZV9jYXJkX3JlcXVlc3QYGiABKAsyOC55YW'
    'xvLmV4dGVybmFsX2NoYW5uZWwuaW5fYXBwLnNkay52MS5HdWlkYW5jZUNhcmRSZXF1ZXN0SABS'
    'E2d1aWRhbmNlQ2FyZFJlcXVlc3QScQoWZ3VpZGFuY2VfY2FyZF9yZXNwb25zZRgbIAEoCzI5Ln'
    'lhbG8uZXh0ZXJuYWxfY2hhbm5lbC5pbl9hcHAuc2RrLnYxLkd1aWRhbmNlQ2FyZFJlc3BvbnNl'
    'SABSFGd1aWRhbmNlQ2FyZFJlc3BvbnNlEm4KFWFkZF9wcm9tb3Rpb25fcmVxdWVzdBgcIAEoCz'
    'I4LnlhbG8uZXh0ZXJuYWxfY2hhbm5lbC5pbl9hcHAuc2RrLnYxLkFkZFByb21vdGlvblJlcXVl'
    'c3RIAFITYWRkUHJvbW90aW9uUmVxdWVzdBJxChZhZGRfcHJvbW90aW9uX3Jlc3BvbnNlGB0gAS'
    'gLMjkueWFsby5leHRlcm5hbF9jaGFubmVsLmluX2FwcC5zZGsudjEuQWRkUHJvbW90aW9uUmVz'
    'cG9uc2VIAFIUYWRkUHJvbW90aW9uUmVzcG9uc2USegoZcHJvbW90aW9uX21lc3NhZ2VfcmVxdW'
    'VzdBgeIAEoCzI8LnlhbG8uZXh0ZXJuYWxfY2hhbm5lbC5pbl9hcHAuc2RrLnYxLlByb21vdGlv'
    'bk1lc3NhZ2VSZXF1ZXN0SABSF3Byb21vdGlvbk1lc3NhZ2VSZXF1ZXN0En0KGnByb21vdGlvbl'
    '9tZXNzYWdlX3Jlc3BvbnNlGB8gASgLMj0ueWFsby5leHRlcm5hbF9jaGFubmVsLmluX2FwcC5z'
    'ZGsudjEuUHJvbW90aW9uTWVzc2FnZVJlc3BvbnNlSABSGHByb21vdGlvbk1lc3NhZ2VSZXNwb2'
    '5zZRJ0Chdwcm9kdWN0X21lc3NhZ2VfcmVxdWVzdBggIAEoCzI6LnlhbG8uZXh0ZXJuYWxfY2hh'
    'bm5lbC5pbl9hcHAuc2RrLnYxLlByb2R1Y3RNZXNzYWdlUmVxdWVzdEgAUhVwcm9kdWN0TWVzc2'
    'FnZVJlcXVlc3QSdwoYcHJvZHVjdF9tZXNzYWdlX3Jlc3BvbnNlGCEgASgLMjsueWFsby5leHRl'
    'cm5hbF9jaGFubmVsLmluX2FwcC5zZGsudjEuUHJvZHVjdE1lc3NhZ2VSZXNwb25zZUgAUhZwcm'
    '9kdWN0TWVzc2FnZVJlc3BvbnNlEmgKE2NoYXRfc3RhdHVzX3JlcXVlc3QYIiABKAsyNi55YWxv'
    'LmV4dGVybmFsX2NoYW5uZWwuaW5fYXBwLnNkay52MS5DaGF0U3RhdHVzUmVxdWVzdEgAUhFjaG'
    'F0U3RhdHVzUmVxdWVzdBJrChRjaGF0X3N0YXR1c19yZXNwb25zZRgjIAEoCzI3LnlhbG8uZXh0'
    'ZXJuYWxfY2hhbm5lbC5pbl9hcHAuc2RrLnYxLkNoYXRTdGF0dXNSZXNwb25zZUgAUhJjaGF0U3'
    'RhdHVzUmVzcG9uc2USbgoVY3VzdG9tX2FjdGlvbl9yZXF1ZXN0GCQgASgLMjgueWFsby5leHRl'
    'cm5hbF9jaGFubmVsLmluX2FwcC5zZGsudjEuQ3VzdG9tQWN0aW9uUmVxdWVzdEgAUhNjdXN0b2'
    '1BY3Rpb25SZXF1ZXN0EnEKFmN1c3RvbV9hY3Rpb25fcmVzcG9uc2UYJSABKAsyOS55YWxvLmV4'
    'dGVybmFsX2NoYW5uZWwuaW5fYXBwLnNkay52MS5DdXN0b21BY3Rpb25SZXNwb25zZUgAUhRjdX'
    'N0b21BY3Rpb25SZXNwb25zZUIJCgdwYXlsb2Fk');

@$core.Deprecated('Use textMessageDescriptor instead')
const TextMessage$json = {
  '1': 'TextMessage',
  '2': [
    {
      '1': 'message_id',
      '3': 1,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'messageId',
      '17': true
    },
    {
      '1': 'timestamp',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
    {'1': 'text', '3': 3, '4': 1, '5': 9, '10': 'text'},
    {
      '1': 'status',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.yalo.external_channel.in_app.sdk.v1.MessageStatus',
      '10': 'status'
    },
    {
      '1': 'role',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.yalo.external_channel.in_app.sdk.v1.MessageRole',
      '10': 'role'
    },
  ],
  '8': [
    {'1': '_message_id'},
  ],
};

/// Descriptor for `TextMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List textMessageDescriptor = $convert.base64Decode(
    'CgtUZXh0TWVzc2FnZRIiCgptZXNzYWdlX2lkGAEgASgJSABSCW1lc3NhZ2VJZIgBARI4Cgl0aW'
    '1lc3RhbXAYAiABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgl0aW1lc3RhbXASEgoE'
    'dGV4dBgDIAEoCVIEdGV4dBJKCgZzdGF0dXMYBCABKA4yMi55YWxvLmV4dGVybmFsX2NoYW5uZW'
    'wuaW5fYXBwLnNkay52MS5NZXNzYWdlU3RhdHVzUgZzdGF0dXMSRAoEcm9sZRgFIAEoDjIwLnlh'
    'bG8uZXh0ZXJuYWxfY2hhbm5lbC5pbl9hcHAuc2RrLnYxLk1lc3NhZ2VSb2xlUgRyb2xlQg0KC1'
    '9tZXNzYWdlX2lk');

@$core.Deprecated('Use textMessageRequestDescriptor instead')
const TextMessageRequest$json = {
  '1': 'TextMessageRequest',
  '2': [
    {
      '1': 'content',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v1.TextMessage',
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
  ],
};

/// Descriptor for `TextMessageRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List textMessageRequestDescriptor = $convert.base64Decode(
    'ChJUZXh0TWVzc2FnZVJlcXVlc3QSSgoHY29udGVudBgBIAEoCzIwLnlhbG8uZXh0ZXJuYWxfY2'
    'hhbm5lbC5pbl9hcHAuc2RrLnYxLlRleHRNZXNzYWdlUgdjb250ZW50EjgKCXRpbWVzdGFtcBgC'
    'IAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCXRpbWVzdGFtcA==');

@$core.Deprecated('Use textMessageResponseDescriptor instead')
const TextMessageResponse$json = {
  '1': 'TextMessageResponse',
  '2': [
    {
      '1': 'status',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.yalo.external_channel.in_app.sdk.v1.ResponseStatus',
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
    {'1': 'message_id', '3': 3, '4': 1, '5': 9, '10': 'messageId'},
  ],
};

/// Descriptor for `TextMessageResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List textMessageResponseDescriptor = $convert.base64Decode(
    'ChNUZXh0TWVzc2FnZVJlc3BvbnNlEksKBnN0YXR1cxgBIAEoDjIzLnlhbG8uZXh0ZXJuYWxfY2'
    'hhbm5lbC5pbl9hcHAuc2RrLnYxLlJlc3BvbnNlU3RhdHVzUgZzdGF0dXMSOAoJdGltZXN0YW1w'
    'GAIgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJdGltZXN0YW1wEh0KCm1lc3NhZ2'
    'VfaWQYAyABKAlSCW1lc3NhZ2VJZA==');

@$core.Deprecated('Use voiceMessageDescriptor instead')
const VoiceMessage$json = {
  '1': 'VoiceMessage',
  '2': [
    {
      '1': 'message_id',
      '3': 1,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'messageId',
      '17': true
    },
    {
      '1': 'timestamp',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
    {'1': 'media_url', '3': 3, '4': 1, '5': 9, '10': 'mediaUrl'},
    {
      '1': 'amplitudes_preview',
      '3': 4,
      '4': 3,
      '5': 2,
      '10': 'amplitudesPreview'
    },
    {'1': 'duration', '3': 5, '4': 1, '5': 1, '10': 'duration'},
    {'1': 'media_type', '3': 6, '4': 1, '5': 9, '10': 'mediaType'},
    {
      '1': 'status',
      '3': 7,
      '4': 1,
      '5': 14,
      '6': '.yalo.external_channel.in_app.sdk.v1.MessageStatus',
      '10': 'status'
    },
    {
      '1': 'role',
      '3': 8,
      '4': 1,
      '5': 14,
      '6': '.yalo.external_channel.in_app.sdk.v1.MessageRole',
      '10': 'role'
    },
  ],
  '8': [
    {'1': '_message_id'},
  ],
};

/// Descriptor for `VoiceMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List voiceMessageDescriptor = $convert.base64Decode(
    'CgxWb2ljZU1lc3NhZ2USIgoKbWVzc2FnZV9pZBgBIAEoCUgAUgltZXNzYWdlSWSIAQESOAoJdG'
    'ltZXN0YW1wGAIgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJdGltZXN0YW1wEhsK'
    'CW1lZGlhX3VybBgDIAEoCVIIbWVkaWFVcmwSLQoSYW1wbGl0dWRlc19wcmV2aWV3GAQgAygCUh'
    'FhbXBsaXR1ZGVzUHJldmlldxIaCghkdXJhdGlvbhgFIAEoAVIIZHVyYXRpb24SHQoKbWVkaWFf'
    'dHlwZRgGIAEoCVIJbWVkaWFUeXBlEkoKBnN0YXR1cxgHIAEoDjIyLnlhbG8uZXh0ZXJuYWxfY2'
    'hhbm5lbC5pbl9hcHAuc2RrLnYxLk1lc3NhZ2VTdGF0dXNSBnN0YXR1cxJECgRyb2xlGAggASgO'
    'MjAueWFsby5leHRlcm5hbF9jaGFubmVsLmluX2FwcC5zZGsudjEuTWVzc2FnZVJvbGVSBHJvbG'
    'VCDQoLX21lc3NhZ2VfaWQ=');

@$core.Deprecated('Use voiceMessageRequestDescriptor instead')
const VoiceMessageRequest$json = {
  '1': 'VoiceMessageRequest',
  '2': [
    {
      '1': 'content',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v1.VoiceMessage',
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
    {'1': 'quick_replies', '3': 3, '4': 3, '5': 9, '10': 'quickReplies'},
  ],
};

/// Descriptor for `VoiceMessageRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List voiceMessageRequestDescriptor = $convert.base64Decode(
    'ChNWb2ljZU1lc3NhZ2VSZXF1ZXN0EksKB2NvbnRlbnQYASABKAsyMS55YWxvLmV4dGVybmFsX2'
    'NoYW5uZWwuaW5fYXBwLnNkay52MS5Wb2ljZU1lc3NhZ2VSB2NvbnRlbnQSOAoJdGltZXN0YW1w'
    'GAIgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJdGltZXN0YW1wEiMKDXF1aWNrX3'
    'JlcGxpZXMYAyADKAlSDHF1aWNrUmVwbGllcw==');

@$core.Deprecated('Use voiceMessageResponseDescriptor instead')
const VoiceMessageResponse$json = {
  '1': 'VoiceMessageResponse',
  '2': [
    {
      '1': 'status',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.yalo.external_channel.in_app.sdk.v1.ResponseStatus',
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
    {'1': 'message_id', '3': 3, '4': 1, '5': 9, '10': 'messageId'},
  ],
};

/// Descriptor for `VoiceMessageResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List voiceMessageResponseDescriptor = $convert.base64Decode(
    'ChRWb2ljZU1lc3NhZ2VSZXNwb25zZRJLCgZzdGF0dXMYASABKA4yMy55YWxvLmV4dGVybmFsX2'
    'NoYW5uZWwuaW5fYXBwLnNkay52MS5SZXNwb25zZVN0YXR1c1IGc3RhdHVzEjgKCXRpbWVzdGFt'
    'cBgCIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCXRpbWVzdGFtcBIdCgptZXNzYW'
    'dlX2lkGAMgASgJUgltZXNzYWdlSWQ=');

@$core.Deprecated('Use imageMessageDescriptor instead')
const ImageMessage$json = {
  '1': 'ImageMessage',
  '2': [
    {
      '1': 'message_id',
      '3': 1,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'messageId',
      '17': true
    },
    {
      '1': 'timestamp',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
    {'1': 'text', '3': 3, '4': 1, '5': 9, '9': 1, '10': 'text', '17': true},
    {'1': 'media_url', '3': 4, '4': 1, '5': 9, '10': 'mediaUrl'},
    {'1': 'media_type', '3': 5, '4': 1, '5': 9, '10': 'mediaType'},
    {
      '1': 'status',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.yalo.external_channel.in_app.sdk.v1.MessageStatus',
      '10': 'status'
    },
    {
      '1': 'role',
      '3': 7,
      '4': 1,
      '5': 14,
      '6': '.yalo.external_channel.in_app.sdk.v1.MessageRole',
      '10': 'role'
    },
  ],
  '8': [
    {'1': '_message_id'},
    {'1': '_text'},
  ],
};

/// Descriptor for `ImageMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List imageMessageDescriptor = $convert.base64Decode(
    'CgxJbWFnZU1lc3NhZ2USIgoKbWVzc2FnZV9pZBgBIAEoCUgAUgltZXNzYWdlSWSIAQESOAoJdG'
    'ltZXN0YW1wGAIgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJdGltZXN0YW1wEhcK'
    'BHRleHQYAyABKAlIAVIEdGV4dIgBARIbCgltZWRpYV91cmwYBCABKAlSCG1lZGlhVXJsEh0KCm'
    '1lZGlhX3R5cGUYBSABKAlSCW1lZGlhVHlwZRJKCgZzdGF0dXMYBiABKA4yMi55YWxvLmV4dGVy'
    'bmFsX2NoYW5uZWwuaW5fYXBwLnNkay52MS5NZXNzYWdlU3RhdHVzUgZzdGF0dXMSRAoEcm9sZR'
    'gHIAEoDjIwLnlhbG8uZXh0ZXJuYWxfY2hhbm5lbC5pbl9hcHAuc2RrLnYxLk1lc3NhZ2VSb2xl'
    'UgRyb2xlQg0KC19tZXNzYWdlX2lkQgcKBV90ZXh0');

@$core.Deprecated('Use imageMessageRequestDescriptor instead')
const ImageMessageRequest$json = {
  '1': 'ImageMessageRequest',
  '2': [
    {
      '1': 'content',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v1.ImageMessage',
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
    {'1': 'quick_replies', '3': 3, '4': 3, '5': 9, '10': 'quickReplies'},
  ],
};

/// Descriptor for `ImageMessageRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List imageMessageRequestDescriptor = $convert.base64Decode(
    'ChNJbWFnZU1lc3NhZ2VSZXF1ZXN0EksKB2NvbnRlbnQYASABKAsyMS55YWxvLmV4dGVybmFsX2'
    'NoYW5uZWwuaW5fYXBwLnNkay52MS5JbWFnZU1lc3NhZ2VSB2NvbnRlbnQSOAoJdGltZXN0YW1w'
    'GAIgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJdGltZXN0YW1wEiMKDXF1aWNrX3'
    'JlcGxpZXMYAyADKAlSDHF1aWNrUmVwbGllcw==');

@$core.Deprecated('Use imageMessageResponseDescriptor instead')
const ImageMessageResponse$json = {
  '1': 'ImageMessageResponse',
  '2': [
    {
      '1': 'status',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.yalo.external_channel.in_app.sdk.v1.ResponseStatus',
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
    {'1': 'message_id', '3': 3, '4': 1, '5': 9, '10': 'messageId'},
  ],
};

/// Descriptor for `ImageMessageResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List imageMessageResponseDescriptor = $convert.base64Decode(
    'ChRJbWFnZU1lc3NhZ2VSZXNwb25zZRJLCgZzdGF0dXMYASABKA4yMy55YWxvLmV4dGVybmFsX2'
    'NoYW5uZWwuaW5fYXBwLnNkay52MS5SZXNwb25zZVN0YXR1c1IGc3RhdHVzEjgKCXRpbWVzdGFt'
    'cBgCIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCXRpbWVzdGFtcBIdCgptZXNzYW'
    'dlX2lkGAMgASgJUgltZXNzYWdlSWQ=');

@$core.Deprecated('Use messageReceiptRequestDescriptor instead')
const MessageReceiptRequest$json = {
  '1': 'MessageReceiptRequest',
  '2': [
    {
      '1': 'status',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.yalo.external_channel.in_app.sdk.v1.MessageStatus',
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
    {'1': 'quick_replies', '3': 4, '4': 3, '5': 9, '10': 'quickReplies'},
  ],
};

/// Descriptor for `MessageReceiptRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageReceiptRequestDescriptor = $convert.base64Decode(
    'ChVNZXNzYWdlUmVjZWlwdFJlcXVlc3QSSgoGc3RhdHVzGAEgASgOMjIueWFsby5leHRlcm5hbF'
    '9jaGFubmVsLmluX2FwcC5zZGsudjEuTWVzc2FnZVN0YXR1c1IGc3RhdHVzEh0KCm1lc3NhZ2Vf'
    'aWQYAiABKAlSCW1lc3NhZ2VJZBI4Cgl0aW1lc3RhbXAYAyABKAsyGi5nb29nbGUucHJvdG9idW'
    'YuVGltZXN0YW1wUgl0aW1lc3RhbXASIwoNcXVpY2tfcmVwbGllcxgEIAMoCVIMcXVpY2tSZXBs'
    'aWVz');

@$core.Deprecated('Use messageReceiptResponseDescriptor instead')
const MessageReceiptResponse$json = {
  '1': 'MessageReceiptResponse',
  '2': [
    {
      '1': 'status',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.yalo.external_channel.in_app.sdk.v1.ResponseStatus',
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

/// Descriptor for `MessageReceiptResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageReceiptResponseDescriptor = $convert.base64Decode(
    'ChZNZXNzYWdlUmVjZWlwdFJlc3BvbnNlEksKBnN0YXR1cxgBIAEoDjIzLnlhbG8uZXh0ZXJuYW'
    'xfY2hhbm5lbC5pbl9hcHAuc2RrLnYxLlJlc3BvbnNlU3RhdHVzUgZzdGF0dXMSOAoJdGltZXN0'
    'YW1wGAIgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJdGltZXN0YW1w');

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
  ],
};

/// Descriptor for `AddToCartRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addToCartRequestDescriptor = $convert.base64Decode(
    'ChBBZGRUb0NhcnRSZXF1ZXN0EhAKA3NrdRgBIAEoCVIDc2t1EjgKCXRpbWVzdGFtcBgCIAEoCz'
    'IaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCXRpbWVzdGFtcBIaCghxdWFudGl0eRgDIAEo'
    'AVIIcXVhbnRpdHk=');

@$core.Deprecated('Use addToCartResponseDescriptor instead')
const AddToCartResponse$json = {
  '1': 'AddToCartResponse',
  '2': [
    {
      '1': 'status',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.yalo.external_channel.in_app.sdk.v1.ResponseStatus',
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
    '5uZWwuaW5fYXBwLnNkay52MS5SZXNwb25zZVN0YXR1c1IGc3RhdHVzEjgKCXRpbWVzdGFtcBgC'
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
  ],
  '8': [
    {'1': '_quantity'},
  ],
};

/// Descriptor for `RemoveFromCartRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List removeFromCartRequestDescriptor = $convert.base64Decode(
    'ChVSZW1vdmVGcm9tQ2FydFJlcXVlc3QSEAoDc2t1GAEgASgJUgNza3USOAoJdGltZXN0YW1wGA'
    'IgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJdGltZXN0YW1wEh8KCHF1YW50aXR5'
    'GAMgASgBSABSCHF1YW50aXR5iAEBQgsKCV9xdWFudGl0eQ==');

@$core.Deprecated('Use removeFromCartResponseDescriptor instead')
const RemoveFromCartResponse$json = {
  '1': 'RemoveFromCartResponse',
  '2': [
    {
      '1': 'status',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.yalo.external_channel.in_app.sdk.v1.ResponseStatus',
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
    'xfY2hhbm5lbC5pbl9hcHAuc2RrLnYxLlJlc3BvbnNlU3RhdHVzUgZzdGF0dXMSOAoJdGltZXN0'
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
      '6': '.yalo.external_channel.in_app.sdk.v1.ResponseStatus',
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
    '5uZWwuaW5fYXBwLnNkay52MS5SZXNwb25zZVN0YXR1c1IGc3RhdHVzEjgKCXRpbWVzdGFtcBgC'
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
  ],
};

/// Descriptor for `GuidanceCardRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List guidanceCardRequestDescriptor = $convert.base64Decode(
    'ChNHdWlkYW5jZUNhcmRSZXF1ZXN0EjgKCXRpbWVzdGFtcBgBIAEoCzIaLmdvb2dsZS5wcm90b2'
    'J1Zi5UaW1lc3RhbXBSCXRpbWVzdGFtcA==');

@$core.Deprecated('Use guidanceCardResponseDescriptor instead')
const GuidanceCardResponse$json = {
  '1': 'GuidanceCardResponse',
  '2': [
    {
      '1': 'status',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.yalo.external_channel.in_app.sdk.v1.ResponseStatus',
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
    'NoYW5uZWwuaW5fYXBwLnNkay52MS5SZXNwb25zZVN0YXR1c1IGc3RhdHVzEjgKCXRpbWVzdGFt'
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
      '6': '.yalo.external_channel.in_app.sdk.v1.ResponseStatus',
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
    'NoYW5uZWwuaW5fYXBwLnNkay52MS5SZXNwb25zZVN0YXR1c1IGc3RhdHVzEjgKCXRpbWVzdGFt'
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
      '6': '.yalo.external_channel.in_app.sdk.v1.ResponseStatus',
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
    '5hbF9jaGFubmVsLmluX2FwcC5zZGsudjEuUmVzcG9uc2VTdGF0dXNSBnN0YXR1cxI4Cgl0aW1l'
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
      '6': '.yalo.external_channel.in_app.sdk.v1.Product',
      '10': 'products'
    },
    {
      '1': 'orientation',
      '3': 2,
      '4': 1,
      '5': 14,
      '6':
          '.yalo.external_channel.in_app.sdk.v1.ProductMessageRequest.Orientation',
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
    'FsX2NoYW5uZWwuaW5fYXBwLnNkay52MS5Qcm9kdWN0Ughwcm9kdWN0cxJoCgtvcmllbnRhdGlv'
    'bhgCIAEoDjJGLnlhbG8uZXh0ZXJuYWxfY2hhbm5lbC5pbl9hcHAuc2RrLnYxLlByb2R1Y3RNZX'
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
      '6': '.yalo.external_channel.in_app.sdk.v1.ResponseStatus',
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
    'xfY2hhbm5lbC5pbl9hcHAuc2RrLnYxLlJlc3BvbnNlU3RhdHVzUgZzdGF0dXMSOAoJdGltZXN0'
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
      '6': '.yalo.external_channel.in_app.sdk.v1.ResponseStatus',
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
    'FubmVsLmluX2FwcC5zZGsudjEuUmVzcG9uc2VTdGF0dXNSBnN0YXR1cxI4Cgl0aW1lc3RhbXAY'
    'AiABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgl0aW1lc3RhbXA=');

@$core.Deprecated('Use customActionRequestDescriptor instead')
const CustomActionRequest$json = {
  '1': 'CustomActionRequest',
  '2': [
    {'1': 'action_id', '3': 1, '4': 1, '5': 9, '10': 'actionId'},
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

/// Descriptor for `CustomActionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List customActionRequestDescriptor = $convert.base64Decode(
    'ChNDdXN0b21BY3Rpb25SZXF1ZXN0EhsKCWFjdGlvbl9pZBgBIAEoCVIIYWN0aW9uSWQSGAoHcG'
    'F5bG9hZBgCIAEoCVIHcGF5bG9hZBI4Cgl0aW1lc3RhbXAYAyABKAsyGi5nb29nbGUucHJvdG9i'
    'dWYuVGltZXN0YW1wUgl0aW1lc3RhbXA=');

@$core.Deprecated('Use customActionResponseDescriptor instead')
const CustomActionResponse$json = {
  '1': 'CustomActionResponse',
  '2': [
    {
      '1': 'status',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.yalo.external_channel.in_app.sdk.v1.ResponseStatus',
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

/// Descriptor for `CustomActionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List customActionResponseDescriptor = $convert.base64Decode(
    'ChRDdXN0b21BY3Rpb25SZXNwb25zZRJLCgZzdGF0dXMYASABKA4yMy55YWxvLmV4dGVybmFsX2'
    'NoYW5uZWwuaW5fYXBwLnNkay52MS5SZXNwb25zZVN0YXR1c1IGc3RhdHVzEhgKB3BheWxvYWQY'
    'AiABKAlSB3BheWxvYWQSOAoJdGltZXN0YW1wGAMgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbW'
    'VzdGFtcFIJdGltZXN0YW1w');

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
      '6': '.yalo.external_channel.in_app.sdk.v1.SdkMessage',
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
    {
      '1': 'status',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.yalo.external_channel.in_app.sdk.v1.MessageStatus',
      '10': 'status'
    },
  ],
};

/// Descriptor for `PollMessageItem`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pollMessageItemDescriptor = $convert.base64Decode(
    'Cg9Qb2xsTWVzc2FnZUl0ZW0SDgoCaWQYASABKAlSAmlkEkkKB21lc3NhZ2UYAiABKAsyLy55YW'
    'xvLmV4dGVybmFsX2NoYW5uZWwuaW5fYXBwLnNkay52MS5TZGtNZXNzYWdlUgdtZXNzYWdlEi4K'
    'BGRhdGUYAyABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgRkYXRlEhcKB3VzZXJfaW'
    'QYBCABKAlSBnVzZXJJZBJKCgZzdGF0dXMYBSABKA4yMi55YWxvLmV4dGVybmFsX2NoYW5uZWwu'
    'aW5fYXBwLnNkay52MS5NZXNzYWdlU3RhdHVzUgZzdGF0dXM=');

@$core.Deprecated('Use messagePollResponseDescriptor instead')
const MessagePollResponse$json = {
  '1': 'MessagePollResponse',
  '2': [
    {
      '1': 'messages',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v1.PollMessageItem',
      '10': 'messages'
    },
  ],
};

/// Descriptor for `MessagePollResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messagePollResponseDescriptor = $convert.base64Decode(
    'ChNNZXNzYWdlUG9sbFJlc3BvbnNlElAKCG1lc3NhZ2VzGAEgAygLMjQueWFsby5leHRlcm5hbF'
    '9jaGFubmVsLmluX2FwcC5zZGsudjEuUG9sbE1lc3NhZ2VJdGVtUghtZXNzYWdlcw==');
