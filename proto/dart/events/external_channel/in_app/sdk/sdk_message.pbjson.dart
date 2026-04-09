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
      '1': 'voice_note_message_request',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v1.VoiceNoteMessageRequest',
      '9': 0,
      '10': 'voiceNoteMessageRequest'
    },
    {
      '1': 'voice_note_message_response',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v1.VoiceNoteMessageResponse',
      '9': 0,
      '10': 'voiceNoteMessageResponse'
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
      '1': 'attachment_message_request',
      '3': 18,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v1.AttachmentMessageRequest',
      '9': 0,
      '10': 'attachmentMessageRequest'
    },
    {
      '1': 'attachment_message_response',
      '3': 19,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v1.AttachmentMessageResponse',
      '9': 0,
      '10': 'attachmentMessageResponse'
    },
    {
      '1': 'video_message_request',
      '3': 38,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v1.VideoMessageRequest',
      '9': 0,
      '10': 'videoMessageRequest'
    },
    {
      '1': 'video_message_response',
      '3': 39,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v1.VideoMessageResponse',
      '9': 0,
      '10': 'videoMessageResponse'
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
    {
      '1': 'buttons_message_request',
      '3': 40,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v1.ButtonsMessageRequest',
      '9': 0,
      '10': 'buttonsMessageRequest'
    },
    {
      '1': 'buttons_message_response',
      '3': 41,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v1.ButtonsMessageResponse',
      '9': 0,
      '10': 'buttonsMessageResponse'
    },
    {
      '1': 'cta_message_request',
      '3': 42,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v1.CTAMessageRequest',
      '9': 0,
      '10': 'ctaMessageRequest'
    },
    {
      '1': 'cta_message_response',
      '3': 43,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v1.CTAMessageResponse',
      '9': 0,
      '10': 'ctaMessageResponse'
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
    'FwcC5zZGsudjEuVGV4dE1lc3NhZ2VSZXNwb25zZUgAUhN0ZXh0TWVzc2FnZVJlc3BvbnNlEnsK'
    'GnZvaWNlX25vdGVfbWVzc2FnZV9yZXF1ZXN0GAwgASgLMjwueWFsby5leHRlcm5hbF9jaGFubm'
    'VsLmluX2FwcC5zZGsudjEuVm9pY2VOb3RlTWVzc2FnZVJlcXVlc3RIAFIXdm9pY2VOb3RlTWVz'
    'c2FnZVJlcXVlc3QSfgobdm9pY2Vfbm90ZV9tZXNzYWdlX3Jlc3BvbnNlGA0gASgLMj0ueWFsby'
    '5leHRlcm5hbF9jaGFubmVsLmluX2FwcC5zZGsudjEuVm9pY2VOb3RlTWVzc2FnZVJlc3BvbnNl'
    'SABSGHZvaWNlTm90ZU1lc3NhZ2VSZXNwb25zZRJuChVpbWFnZV9tZXNzYWdlX3JlcXVlc3QYDi'
    'ABKAsyOC55YWxvLmV4dGVybmFsX2NoYW5uZWwuaW5fYXBwLnNkay52MS5JbWFnZU1lc3NhZ2VS'
    'ZXF1ZXN0SABSE2ltYWdlTWVzc2FnZVJlcXVlc3QScQoWaW1hZ2VfbWVzc2FnZV9yZXNwb25zZR'
    'gPIAEoCzI5LnlhbG8uZXh0ZXJuYWxfY2hhbm5lbC5pbl9hcHAuc2RrLnYxLkltYWdlTWVzc2Fn'
    'ZVJlc3BvbnNlSABSFGltYWdlTWVzc2FnZVJlc3BvbnNlEnQKF21lc3NhZ2VfcmVjZWlwdF9yZX'
    'F1ZXN0GBAgASgLMjoueWFsby5leHRlcm5hbF9jaGFubmVsLmluX2FwcC5zZGsudjEuTWVzc2Fn'
    'ZVJlY2VpcHRSZXF1ZXN0SABSFW1lc3NhZ2VSZWNlaXB0UmVxdWVzdBJ3ChhtZXNzYWdlX3JlY2'
    'VpcHRfcmVzcG9uc2UYESABKAsyOy55YWxvLmV4dGVybmFsX2NoYW5uZWwuaW5fYXBwLnNkay52'
    'MS5NZXNzYWdlUmVjZWlwdFJlc3BvbnNlSABSFm1lc3NhZ2VSZWNlaXB0UmVzcG9uc2USfQoaYX'
    'R0YWNobWVudF9tZXNzYWdlX3JlcXVlc3QYEiABKAsyPS55YWxvLmV4dGVybmFsX2NoYW5uZWwu'
    'aW5fYXBwLnNkay52MS5BdHRhY2htZW50TWVzc2FnZVJlcXVlc3RIAFIYYXR0YWNobWVudE1lc3'
    'NhZ2VSZXF1ZXN0EoABChthdHRhY2htZW50X21lc3NhZ2VfcmVzcG9uc2UYEyABKAsyPi55YWxv'
    'LmV4dGVybmFsX2NoYW5uZWwuaW5fYXBwLnNkay52MS5BdHRhY2htZW50TWVzc2FnZVJlc3Bvbn'
    'NlSABSGWF0dGFjaG1lbnRNZXNzYWdlUmVzcG9uc2USbgoVdmlkZW9fbWVzc2FnZV9yZXF1ZXN0'
    'GCYgASgLMjgueWFsby5leHRlcm5hbF9jaGFubmVsLmluX2FwcC5zZGsudjEuVmlkZW9NZXNzYW'
    'dlUmVxdWVzdEgAUhN2aWRlb01lc3NhZ2VSZXF1ZXN0EnEKFnZpZGVvX21lc3NhZ2VfcmVzcG9u'
    'c2UYJyABKAsyOS55YWxvLmV4dGVybmFsX2NoYW5uZWwuaW5fYXBwLnNkay52MS5WaWRlb01lc3'
    'NhZ2VSZXNwb25zZUgAUhR2aWRlb01lc3NhZ2VSZXNwb25zZRJmChNhZGRfdG9fY2FydF9yZXF1'
    'ZXN0GBQgASgLMjUueWFsby5leHRlcm5hbF9jaGFubmVsLmluX2FwcC5zZGsudjEuQWRkVG9DYX'
    'J0UmVxdWVzdEgAUhBhZGRUb0NhcnRSZXF1ZXN0EmkKFGFkZF90b19jYXJ0X3Jlc3BvbnNlGBUg'
    'ASgLMjYueWFsby5leHRlcm5hbF9jaGFubmVsLmluX2FwcC5zZGsudjEuQWRkVG9DYXJ0UmVzcG'
    '9uc2VIAFIRYWRkVG9DYXJ0UmVzcG9uc2USdQoYcmVtb3ZlX2Zyb21fY2FydF9yZXF1ZXN0GBYg'
    'ASgLMjoueWFsby5leHRlcm5hbF9jaGFubmVsLmluX2FwcC5zZGsudjEuUmVtb3ZlRnJvbUNhcn'
    'RSZXF1ZXN0SABSFXJlbW92ZUZyb21DYXJ0UmVxdWVzdBJ4ChlyZW1vdmVfZnJvbV9jYXJ0X3Jl'
    'c3BvbnNlGBcgASgLMjsueWFsby5leHRlcm5hbF9jaGFubmVsLmluX2FwcC5zZGsudjEuUmVtb3'
    'ZlRnJvbUNhcnRSZXNwb25zZUgAUhZyZW1vdmVGcm9tQ2FydFJlc3BvbnNlEmUKEmNsZWFyX2Nh'
    'cnRfcmVxdWVzdBgYIAEoCzI1LnlhbG8uZXh0ZXJuYWxfY2hhbm5lbC5pbl9hcHAuc2RrLnYxLk'
    'NsZWFyQ2FydFJlcXVlc3RIAFIQY2xlYXJDYXJ0UmVxdWVzdBJoChNjbGVhcl9jYXJ0X3Jlc3Bv'
    'bnNlGBkgASgLMjYueWFsby5leHRlcm5hbF9jaGFubmVsLmluX2FwcC5zZGsudjEuQ2xlYXJDYX'
    'J0UmVzcG9uc2VIAFIRY2xlYXJDYXJ0UmVzcG9uc2USbgoVZ3VpZGFuY2VfY2FyZF9yZXF1ZXN0'
    'GBogASgLMjgueWFsby5leHRlcm5hbF9jaGFubmVsLmluX2FwcC5zZGsudjEuR3VpZGFuY2VDYX'
    'JkUmVxdWVzdEgAUhNndWlkYW5jZUNhcmRSZXF1ZXN0EnEKFmd1aWRhbmNlX2NhcmRfcmVzcG9u'
    'c2UYGyABKAsyOS55YWxvLmV4dGVybmFsX2NoYW5uZWwuaW5fYXBwLnNkay52MS5HdWlkYW5jZU'
    'NhcmRSZXNwb25zZUgAUhRndWlkYW5jZUNhcmRSZXNwb25zZRJuChVhZGRfcHJvbW90aW9uX3Jl'
    'cXVlc3QYHCABKAsyOC55YWxvLmV4dGVybmFsX2NoYW5uZWwuaW5fYXBwLnNkay52MS5BZGRQcm'
    '9tb3Rpb25SZXF1ZXN0SABSE2FkZFByb21vdGlvblJlcXVlc3QScQoWYWRkX3Byb21vdGlvbl9y'
    'ZXNwb25zZRgdIAEoCzI5LnlhbG8uZXh0ZXJuYWxfY2hhbm5lbC5pbl9hcHAuc2RrLnYxLkFkZF'
    'Byb21vdGlvblJlc3BvbnNlSABSFGFkZFByb21vdGlvblJlc3BvbnNlEnoKGXByb21vdGlvbl9t'
    'ZXNzYWdlX3JlcXVlc3QYHiABKAsyPC55YWxvLmV4dGVybmFsX2NoYW5uZWwuaW5fYXBwLnNkay'
    '52MS5Qcm9tb3Rpb25NZXNzYWdlUmVxdWVzdEgAUhdwcm9tb3Rpb25NZXNzYWdlUmVxdWVzdBJ9'
    'Chpwcm9tb3Rpb25fbWVzc2FnZV9yZXNwb25zZRgfIAEoCzI9LnlhbG8uZXh0ZXJuYWxfY2hhbm'
    '5lbC5pbl9hcHAuc2RrLnYxLlByb21vdGlvbk1lc3NhZ2VSZXNwb25zZUgAUhhwcm9tb3Rpb25N'
    'ZXNzYWdlUmVzcG9uc2USdAoXcHJvZHVjdF9tZXNzYWdlX3JlcXVlc3QYICABKAsyOi55YWxvLm'
    'V4dGVybmFsX2NoYW5uZWwuaW5fYXBwLnNkay52MS5Qcm9kdWN0TWVzc2FnZVJlcXVlc3RIAFIV'
    'cHJvZHVjdE1lc3NhZ2VSZXF1ZXN0EncKGHByb2R1Y3RfbWVzc2FnZV9yZXNwb25zZRghIAEoCz'
    'I7LnlhbG8uZXh0ZXJuYWxfY2hhbm5lbC5pbl9hcHAuc2RrLnYxLlByb2R1Y3RNZXNzYWdlUmVz'
    'cG9uc2VIAFIWcHJvZHVjdE1lc3NhZ2VSZXNwb25zZRJoChNjaGF0X3N0YXR1c19yZXF1ZXN0GC'
    'IgASgLMjYueWFsby5leHRlcm5hbF9jaGFubmVsLmluX2FwcC5zZGsudjEuQ2hhdFN0YXR1c1Jl'
    'cXVlc3RIAFIRY2hhdFN0YXR1c1JlcXVlc3QSawoUY2hhdF9zdGF0dXNfcmVzcG9uc2UYIyABKA'
    'syNy55YWxvLmV4dGVybmFsX2NoYW5uZWwuaW5fYXBwLnNkay52MS5DaGF0U3RhdHVzUmVzcG9u'
    'c2VIAFISY2hhdFN0YXR1c1Jlc3BvbnNlEm4KFWN1c3RvbV9hY3Rpb25fcmVxdWVzdBgkIAEoCz'
    'I4LnlhbG8uZXh0ZXJuYWxfY2hhbm5lbC5pbl9hcHAuc2RrLnYxLkN1c3RvbUFjdGlvblJlcXVl'
    'c3RIAFITY3VzdG9tQWN0aW9uUmVxdWVzdBJxChZjdXN0b21fYWN0aW9uX3Jlc3BvbnNlGCUgAS'
    'gLMjkueWFsby5leHRlcm5hbF9jaGFubmVsLmluX2FwcC5zZGsudjEuQ3VzdG9tQWN0aW9uUmVz'
    'cG9uc2VIAFIUY3VzdG9tQWN0aW9uUmVzcG9uc2USdAoXYnV0dG9uc19tZXNzYWdlX3JlcXVlc3'
    'QYKCABKAsyOi55YWxvLmV4dGVybmFsX2NoYW5uZWwuaW5fYXBwLnNkay52MS5CdXR0b25zTWVz'
    'c2FnZVJlcXVlc3RIAFIVYnV0dG9uc01lc3NhZ2VSZXF1ZXN0EncKGGJ1dHRvbnNfbWVzc2FnZV'
    '9yZXNwb25zZRgpIAEoCzI7LnlhbG8uZXh0ZXJuYWxfY2hhbm5lbC5pbl9hcHAuc2RrLnYxLkJ1'
    'dHRvbnNNZXNzYWdlUmVzcG9uc2VIAFIWYnV0dG9uc01lc3NhZ2VSZXNwb25zZRJoChNjdGFfbW'
    'Vzc2FnZV9yZXF1ZXN0GCogASgLMjYueWFsby5leHRlcm5hbF9jaGFubmVsLmluX2FwcC5zZGsu'
    'djEuQ1RBTWVzc2FnZVJlcXVlc3RIAFIRY3RhTWVzc2FnZVJlcXVlc3QSawoUY3RhX21lc3NhZ2'
    'VfcmVzcG9uc2UYKyABKAsyNy55YWxvLmV4dGVybmFsX2NoYW5uZWwuaW5fYXBwLnNkay52MS5D'
    'VEFNZXNzYWdlUmVzcG9uc2VIAFISY3RhTWVzc2FnZVJlc3BvbnNlQgkKB3BheWxvYWQ=');

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
      '6': '.yalo.external_channel.in_app.sdk.v1.MessageStatus',
      '10': 'status'
    },
    {
      '1': 'role',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.yalo.external_channel.in_app.sdk.v1.MessageRole',
      '10': 'role'
    },
  ],
};

/// Descriptor for `TextMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List textMessageDescriptor = $convert.base64Decode(
    'CgtUZXh0TWVzc2FnZRI4Cgl0aW1lc3RhbXAYASABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZX'
    'N0YW1wUgl0aW1lc3RhbXASEgoEdGV4dBgCIAEoCVIEdGV4dBJKCgZzdGF0dXMYAyABKA4yMi55'
    'YWxvLmV4dGVybmFsX2NoYW5uZWwuaW5fYXBwLnNkay52MS5NZXNzYWdlU3RhdHVzUgZzdGF0dX'
    'MSRAoEcm9sZRgEIAEoDjIwLnlhbG8uZXh0ZXJuYWxfY2hhbm5lbC5pbl9hcHAuc2RrLnYxLk1l'
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
    'DjIyLnlhbG8uZXh0ZXJuYWxfY2hhbm5lbC5pbl9hcHAuc2RrLnYxLk1lc3NhZ2VTdGF0dXNSBn'
    'N0YXR1cxJECgRyb2xlGAcgASgOMjAueWFsby5leHRlcm5hbF9jaGFubmVsLmluX2FwcC5zZGsu'
    'djEuTWVzc2FnZVJvbGVSBHJvbGUSHQoKYnl0ZV9jb3VudBgIIAEoA1IJYnl0ZUNvdW50EhsKCW'
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

/// Descriptor for `VoiceNoteMessageRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List voiceNoteMessageRequestDescriptor = $convert.base64Decode(
    'ChdWb2ljZU5vdGVNZXNzYWdlUmVxdWVzdBJLCgdjb250ZW50GAEgASgLMjEueWFsby5leHRlcm'
    '5hbF9jaGFubmVsLmluX2FwcC5zZGsudjEuVm9pY2VNZXNzYWdlUgdjb250ZW50EjgKCXRpbWVz'
    'dGFtcBgCIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCXRpbWVzdGFtcBIjCg1xdW'
    'lja19yZXBsaWVzGAMgAygJUgxxdWlja1JlcGxpZXM=');

@$core.Deprecated('Use voiceNoteMessageResponseDescriptor instead')
const VoiceNoteMessageResponse$json = {
  '1': 'VoiceNoteMessageResponse',
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

/// Descriptor for `VoiceNoteMessageResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List voiceNoteMessageResponseDescriptor = $convert.base64Decode(
    'ChhWb2ljZU5vdGVNZXNzYWdlUmVzcG9uc2USSwoGc3RhdHVzGAEgASgOMjMueWFsby5leHRlcm'
    '5hbF9jaGFubmVsLmluX2FwcC5zZGsudjEuUmVzcG9uc2VTdGF0dXNSBnN0YXR1cxI4Cgl0aW1l'
    'c3RhbXAYAiABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgl0aW1lc3RhbXASHQoKbW'
    'Vzc2FnZV9pZBgDIAEoCVIJbWVzc2FnZUlk');

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
      '6': '.yalo.external_channel.in_app.sdk.v1.MessageStatus',
      '10': 'status'
    },
    {
      '1': 'role',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.yalo.external_channel.in_app.sdk.v1.MessageRole',
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
    'MYBSABKA4yMi55YWxvLmV4dGVybmFsX2NoYW5uZWwuaW5fYXBwLnNkay52MS5NZXNzYWdlU3Rh'
    'dHVzUgZzdGF0dXMSRAoEcm9sZRgGIAEoDjIwLnlhbG8uZXh0ZXJuYWxfY2hhbm5lbC5pbl9hcH'
    'Auc2RrLnYxLk1lc3NhZ2VSb2xlUgRyb2xlEh0KCmJ5dGVfY291bnQYByABKANSCWJ5dGVDb3Vu'
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
      '6': '.yalo.external_channel.in_app.sdk.v1.MessageStatus',
      '10': 'status'
    },
    {
      '1': 'role',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.yalo.external_channel.in_app.sdk.v1.MessageRole',
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
    'N0YXR1cxgFIAEoDjIyLnlhbG8uZXh0ZXJuYWxfY2hhbm5lbC5pbl9hcHAuc2RrLnYxLk1lc3Nh'
    'Z2VTdGF0dXNSBnN0YXR1cxJECgRyb2xlGAYgASgOMjAueWFsby5leHRlcm5hbF9jaGFubmVsLm'
    'luX2FwcC5zZGsudjEuTWVzc2FnZVJvbGVSBHJvbGUSHQoKYnl0ZV9jb3VudBgHIAEoA1IJYnl0'
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
      '6': '.yalo.external_channel.in_app.sdk.v1.AttachmentMessage',
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

/// Descriptor for `AttachmentMessageRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List attachmentMessageRequestDescriptor = $convert.base64Decode(
    'ChhBdHRhY2htZW50TWVzc2FnZVJlcXVlc3QSUAoHY29udGVudBgBIAEoCzI2LnlhbG8uZXh0ZX'
    'JuYWxfY2hhbm5lbC5pbl9hcHAuc2RrLnYxLkF0dGFjaG1lbnRNZXNzYWdlUgdjb250ZW50EjgK'
    'CXRpbWVzdGFtcBgCIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCXRpbWVzdGFtcB'
    'IjCg1xdWlja19yZXBsaWVzGAMgAygJUgxxdWlja1JlcGxpZXM=');

@$core.Deprecated('Use attachmentMessageResponseDescriptor instead')
const AttachmentMessageResponse$json = {
  '1': 'AttachmentMessageResponse',
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

/// Descriptor for `AttachmentMessageResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List attachmentMessageResponseDescriptor = $convert.base64Decode(
    'ChlBdHRhY2htZW50TWVzc2FnZVJlc3BvbnNlEksKBnN0YXR1cxgBIAEoDjIzLnlhbG8uZXh0ZX'
    'JuYWxfY2hhbm5lbC5pbl9hcHAuc2RrLnYxLlJlc3BvbnNlU3RhdHVzUgZzdGF0dXMSOAoJdGlt'
    'ZXN0YW1wGAIgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJdGltZXN0YW1wEh0KCm'
    '1lc3NhZ2VfaWQYAyABKAlSCW1lc3NhZ2VJZA==');

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
      '6': '.yalo.external_channel.in_app.sdk.v1.MessageStatus',
      '10': 'status'
    },
    {
      '1': 'role',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.yalo.external_channel.in_app.sdk.v1.MessageRole',
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
    'MYBSABKA4yMi55YWxvLmV4dGVybmFsX2NoYW5uZWwuaW5fYXBwLnNkay52MS5NZXNzYWdlU3Rh'
    'dHVzUgZzdGF0dXMSRAoEcm9sZRgGIAEoDjIwLnlhbG8uZXh0ZXJuYWxfY2hhbm5lbC5pbl9hcH'
    'Auc2RrLnYxLk1lc3NhZ2VSb2xlUgRyb2xlEh0KCmJ5dGVfY291bnQYByABKANSCWJ5dGVDb3Vu'
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
      '6': '.yalo.external_channel.in_app.sdk.v1.VideoMessage',
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

/// Descriptor for `VideoMessageRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List videoMessageRequestDescriptor = $convert.base64Decode(
    'ChNWaWRlb01lc3NhZ2VSZXF1ZXN0EksKB2NvbnRlbnQYASABKAsyMS55YWxvLmV4dGVybmFsX2'
    'NoYW5uZWwuaW5fYXBwLnNkay52MS5WaWRlb01lc3NhZ2VSB2NvbnRlbnQSOAoJdGltZXN0YW1w'
    'GAIgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJdGltZXN0YW1wEiMKDXF1aWNrX3'
    'JlcGxpZXMYAyADKAlSDHF1aWNrUmVwbGllcw==');

@$core.Deprecated('Use videoMessageResponseDescriptor instead')
const VideoMessageResponse$json = {
  '1': 'VideoMessageResponse',
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

/// Descriptor for `VideoMessageResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List videoMessageResponseDescriptor = $convert.base64Decode(
    'ChRWaWRlb01lc3NhZ2VSZXNwb25zZRJLCgZzdGF0dXMYASABKA4yMy55YWxvLmV4dGVybmFsX2'
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

@$core.Deprecated('Use buttonsMessageDescriptor instead')
const ButtonsMessage$json = {
  '1': 'ButtonsMessage',
  '2': [
    {'1': 'header', '3': 1, '4': 1, '5': 9, '10': 'header'},
    {'1': 'body', '3': 2, '4': 1, '5': 9, '10': 'body'},
    {'1': 'footer', '3': 3, '4': 1, '5': 9, '10': 'footer'},
    {'1': 'buttons', '3': 4, '4': 3, '5': 9, '10': 'buttons'},
  ],
};

/// Descriptor for `ButtonsMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List buttonsMessageDescriptor = $convert.base64Decode(
    'Cg5CdXR0b25zTWVzc2FnZRIWCgZoZWFkZXIYASABKAlSBmhlYWRlchISCgRib2R5GAIgASgJUg'
    'Rib2R5EhYKBmZvb3RlchgDIAEoCVIGZm9vdGVyEhgKB2J1dHRvbnMYBCADKAlSB2J1dHRvbnM=');

@$core.Deprecated('Use buttonsMessageRequestDescriptor instead')
const ButtonsMessageRequest$json = {
  '1': 'ButtonsMessageRequest',
  '2': [
    {
      '1': 'content',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v1.ButtonsMessage',
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

/// Descriptor for `ButtonsMessageRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List buttonsMessageRequestDescriptor = $convert.base64Decode(
    'ChVCdXR0b25zTWVzc2FnZVJlcXVlc3QSTQoHY29udGVudBgBIAEoCzIzLnlhbG8uZXh0ZXJuYW'
    'xfY2hhbm5lbC5pbl9hcHAuc2RrLnYxLkJ1dHRvbnNNZXNzYWdlUgdjb250ZW50EjgKCXRpbWVz'
    'dGFtcBgCIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCXRpbWVzdGFtcA==');

@$core.Deprecated('Use buttonsMessageResponseDescriptor instead')
const ButtonsMessageResponse$json = {
  '1': 'ButtonsMessageResponse',
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

/// Descriptor for `ButtonsMessageResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List buttonsMessageResponseDescriptor = $convert.base64Decode(
    'ChZCdXR0b25zTWVzc2FnZVJlc3BvbnNlEksKBnN0YXR1cxgBIAEoDjIzLnlhbG8uZXh0ZXJuYW'
    'xfY2hhbm5lbC5pbl9hcHAuc2RrLnYxLlJlc3BvbnNlU3RhdHVzUgZzdGF0dXMSOAoJdGltZXN0'
    'YW1wGAIgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJdGltZXN0YW1wEh0KCm1lc3'
    'NhZ2VfaWQYAyABKAlSCW1lc3NhZ2VJZA==');

@$core.Deprecated('Use cTAButtonDescriptor instead')
const CTAButton$json = {
  '1': 'CTAButton',
  '2': [
    {'1': 'text', '3': 1, '4': 1, '5': 9, '10': 'text'},
    {'1': 'url', '3': 2, '4': 1, '5': 9, '10': 'url'},
  ],
};

/// Descriptor for `CTAButton`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cTAButtonDescriptor = $convert.base64Decode(
    'CglDVEFCdXR0b24SEgoEdGV4dBgBIAEoCVIEdGV4dBIQCgN1cmwYAiABKAlSA3VybA==');

@$core.Deprecated('Use cTAMessageDescriptor instead')
const CTAMessage$json = {
  '1': 'CTAMessage',
  '2': [
    {'1': 'header', '3': 1, '4': 1, '5': 9, '10': 'header'},
    {'1': 'body', '3': 2, '4': 1, '5': 9, '10': 'body'},
    {'1': 'footer', '3': 3, '4': 1, '5': 9, '10': 'footer'},
    {
      '1': 'buttons',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v1.CTAButton',
      '10': 'buttons'
    },
  ],
};

/// Descriptor for `CTAMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cTAMessageDescriptor = $convert.base64Decode(
    'CgpDVEFNZXNzYWdlEhYKBmhlYWRlchgBIAEoCVIGaGVhZGVyEhIKBGJvZHkYAiABKAlSBGJvZH'
    'kSFgoGZm9vdGVyGAMgASgJUgZmb290ZXISSAoHYnV0dG9ucxgEIAMoCzIuLnlhbG8uZXh0ZXJu'
    'YWxfY2hhbm5lbC5pbl9hcHAuc2RrLnYxLkNUQUJ1dHRvblIHYnV0dG9ucw==');

@$core.Deprecated('Use cTAMessageRequestDescriptor instead')
const CTAMessageRequest$json = {
  '1': 'CTAMessageRequest',
  '2': [
    {
      '1': 'content',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.yalo.external_channel.in_app.sdk.v1.CTAMessage',
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

/// Descriptor for `CTAMessageRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cTAMessageRequestDescriptor = $convert.base64Decode(
    'ChFDVEFNZXNzYWdlUmVxdWVzdBJJCgdjb250ZW50GAEgASgLMi8ueWFsby5leHRlcm5hbF9jaG'
    'FubmVsLmluX2FwcC5zZGsudjEuQ1RBTWVzc2FnZVIHY29udGVudBI4Cgl0aW1lc3RhbXAYAiAB'
    'KAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgl0aW1lc3RhbXA=');

@$core.Deprecated('Use cTAMessageResponseDescriptor instead')
const CTAMessageResponse$json = {
  '1': 'CTAMessageResponse',
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

/// Descriptor for `CTAMessageResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cTAMessageResponseDescriptor = $convert.base64Decode(
    'ChJDVEFNZXNzYWdlUmVzcG9uc2USSwoGc3RhdHVzGAEgASgOMjMueWFsby5leHRlcm5hbF9jaG'
    'FubmVsLmluX2FwcC5zZGsudjEuUmVzcG9uc2VTdGF0dXNSBnN0YXR1cxI4Cgl0aW1lc3RhbXAY'
    'AiABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgl0aW1lc3RhbXASHQoKbWVzc2FnZV'
    '9pZBgDIAEoCVIJbWVzc2FnZUlk');

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
    {'1': 'status', '3': 5, '4': 1, '5': 9, '10': 'status'},
  ],
};

/// Descriptor for `PollMessageItem`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pollMessageItemDescriptor = $convert.base64Decode(
    'Cg9Qb2xsTWVzc2FnZUl0ZW0SDgoCaWQYASABKAlSAmlkEkkKB21lc3NhZ2UYAiABKAsyLy55YW'
    'xvLmV4dGVybmFsX2NoYW5uZWwuaW5fYXBwLnNkay52MS5TZGtNZXNzYWdlUgdtZXNzYWdlEi4K'
    'BGRhdGUYAyABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgRkYXRlEhcKB3VzZXJfaW'
    'QYBCABKAlSBnVzZXJJZBIWCgZzdGF0dXMYBSABKAlSBnN0YXR1cw==');
