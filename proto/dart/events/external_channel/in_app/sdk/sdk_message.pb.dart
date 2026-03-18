// This is a generated file - do not edit.
//
// Generated from events/external_channel/in_app/sdk/sdk_message.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart'
    as $0;

import 'sdk_message.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'sdk_message.pbenum.dart';

enum SdkMessage_Payload {
  textMessageRequest,
  textMessageResponse,
  voiceMessageRequest,
  voiceMessageResponse,
  imageMessageRequest,
  imageMessageResponse,
  messageReceiptRequest,
  messageReceiptResponse,
  addToCartRequest,
  addToCartResponse,
  removeFromCartRequest,
  removeFromCartResponse,
  clearCartRequest,
  clearCartResponse,
  guidanceCardRequest,
  guidanceCardResponse,
  addPromotionRequest,
  addPromotionResponse,
  promotionMessageRequest,
  promotionMessageResponse,
  productMessageRequest,
  productMessageResponse,
  chatStatusRequest,
  chatStatusResponse,
  customActionRequest,
  customActionResponse,
  notSet
}

/// SdkMessage is the top-level wrapper sent over the bidirectional stream.
/// Exactly one payload field is set per message; the oneof lets the Go runtime
/// expose a type-switch-friendly isSdkMessage_Payload interface.
class SdkMessage extends $pb.GeneratedMessage {
  factory SdkMessage({
    $core.String? correlationId,
    $0.Timestamp? timestamp,
    TextMessageRequest? textMessageRequest,
    TextMessageResponse? textMessageResponse,
    VoiceMessageRequest? voiceMessageRequest,
    VoiceMessageResponse? voiceMessageResponse,
    ImageMessageRequest? imageMessageRequest,
    ImageMessageResponse? imageMessageResponse,
    MessageReceiptRequest? messageReceiptRequest,
    MessageReceiptResponse? messageReceiptResponse,
    AddToCartRequest? addToCartRequest,
    AddToCartResponse? addToCartResponse,
    RemoveFromCartRequest? removeFromCartRequest,
    RemoveFromCartResponse? removeFromCartResponse,
    ClearCartRequest? clearCartRequest,
    ClearCartResponse? clearCartResponse,
    GuidanceCardRequest? guidanceCardRequest,
    GuidanceCardResponse? guidanceCardResponse,
    AddPromotionRequest? addPromotionRequest,
    AddPromotionResponse? addPromotionResponse,
    PromotionMessageRequest? promotionMessageRequest,
    PromotionMessageResponse? promotionMessageResponse,
    ProductMessageRequest? productMessageRequest,
    ProductMessageResponse? productMessageResponse,
    ChatStatusRequest? chatStatusRequest,
    ChatStatusResponse? chatStatusResponse,
    CustomActionRequest? customActionRequest,
    CustomActionResponse? customActionResponse,
  }) {
    final result = create();
    if (correlationId != null) result.correlationId = correlationId;
    if (timestamp != null) result.timestamp = timestamp;
    if (textMessageRequest != null)
      result.textMessageRequest = textMessageRequest;
    if (textMessageResponse != null)
      result.textMessageResponse = textMessageResponse;
    if (voiceMessageRequest != null)
      result.voiceMessageRequest = voiceMessageRequest;
    if (voiceMessageResponse != null)
      result.voiceMessageResponse = voiceMessageResponse;
    if (imageMessageRequest != null)
      result.imageMessageRequest = imageMessageRequest;
    if (imageMessageResponse != null)
      result.imageMessageResponse = imageMessageResponse;
    if (messageReceiptRequest != null)
      result.messageReceiptRequest = messageReceiptRequest;
    if (messageReceiptResponse != null)
      result.messageReceiptResponse = messageReceiptResponse;
    if (addToCartRequest != null) result.addToCartRequest = addToCartRequest;
    if (addToCartResponse != null) result.addToCartResponse = addToCartResponse;
    if (removeFromCartRequest != null)
      result.removeFromCartRequest = removeFromCartRequest;
    if (removeFromCartResponse != null)
      result.removeFromCartResponse = removeFromCartResponse;
    if (clearCartRequest != null) result.clearCartRequest = clearCartRequest;
    if (clearCartResponse != null) result.clearCartResponse = clearCartResponse;
    if (guidanceCardRequest != null)
      result.guidanceCardRequest = guidanceCardRequest;
    if (guidanceCardResponse != null)
      result.guidanceCardResponse = guidanceCardResponse;
    if (addPromotionRequest != null)
      result.addPromotionRequest = addPromotionRequest;
    if (addPromotionResponse != null)
      result.addPromotionResponse = addPromotionResponse;
    if (promotionMessageRequest != null)
      result.promotionMessageRequest = promotionMessageRequest;
    if (promotionMessageResponse != null)
      result.promotionMessageResponse = promotionMessageResponse;
    if (productMessageRequest != null)
      result.productMessageRequest = productMessageRequest;
    if (productMessageResponse != null)
      result.productMessageResponse = productMessageResponse;
    if (chatStatusRequest != null) result.chatStatusRequest = chatStatusRequest;
    if (chatStatusResponse != null)
      result.chatStatusResponse = chatStatusResponse;
    if (customActionRequest != null)
      result.customActionRequest = customActionRequest;
    if (customActionResponse != null)
      result.customActionResponse = customActionResponse;
    return result;
  }

  SdkMessage._();

  factory SdkMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SdkMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, SdkMessage_Payload>
      _SdkMessage_PayloadByTag = {
    10: SdkMessage_Payload.textMessageRequest,
    11: SdkMessage_Payload.textMessageResponse,
    12: SdkMessage_Payload.voiceMessageRequest,
    13: SdkMessage_Payload.voiceMessageResponse,
    14: SdkMessage_Payload.imageMessageRequest,
    15: SdkMessage_Payload.imageMessageResponse,
    16: SdkMessage_Payload.messageReceiptRequest,
    17: SdkMessage_Payload.messageReceiptResponse,
    20: SdkMessage_Payload.addToCartRequest,
    21: SdkMessage_Payload.addToCartResponse,
    22: SdkMessage_Payload.removeFromCartRequest,
    23: SdkMessage_Payload.removeFromCartResponse,
    24: SdkMessage_Payload.clearCartRequest,
    25: SdkMessage_Payload.clearCartResponse,
    26: SdkMessage_Payload.guidanceCardRequest,
    27: SdkMessage_Payload.guidanceCardResponse,
    28: SdkMessage_Payload.addPromotionRequest,
    29: SdkMessage_Payload.addPromotionResponse,
    30: SdkMessage_Payload.promotionMessageRequest,
    31: SdkMessage_Payload.promotionMessageResponse,
    32: SdkMessage_Payload.productMessageRequest,
    33: SdkMessage_Payload.productMessageResponse,
    34: SdkMessage_Payload.chatStatusRequest,
    35: SdkMessage_Payload.chatStatusResponse,
    36: SdkMessage_Payload.customActionRequest,
    37: SdkMessage_Payload.customActionResponse,
    0: SdkMessage_Payload.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SdkMessage',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v1'),
      createEmptyInstance: create)
    ..oo(0, [
      10,
      11,
      12,
      13,
      14,
      15,
      16,
      17,
      20,
      21,
      22,
      23,
      24,
      25,
      26,
      27,
      28,
      29,
      30,
      31,
      32,
      33,
      34,
      35,
      36,
      37
    ])
    ..aOS(1, _omitFieldNames ? '' : 'correlationId')
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..aOM<TextMessageRequest>(10, _omitFieldNames ? '' : 'textMessageRequest',
        subBuilder: TextMessageRequest.create)
    ..aOM<TextMessageResponse>(11, _omitFieldNames ? '' : 'textMessageResponse',
        subBuilder: TextMessageResponse.create)
    ..aOM<VoiceMessageRequest>(12, _omitFieldNames ? '' : 'voiceMessageRequest',
        subBuilder: VoiceMessageRequest.create)
    ..aOM<VoiceMessageResponse>(
        13, _omitFieldNames ? '' : 'voiceMessageResponse',
        subBuilder: VoiceMessageResponse.create)
    ..aOM<ImageMessageRequest>(14, _omitFieldNames ? '' : 'imageMessageRequest',
        subBuilder: ImageMessageRequest.create)
    ..aOM<ImageMessageResponse>(
        15, _omitFieldNames ? '' : 'imageMessageResponse',
        subBuilder: ImageMessageResponse.create)
    ..aOM<MessageReceiptRequest>(
        16, _omitFieldNames ? '' : 'messageReceiptRequest',
        subBuilder: MessageReceiptRequest.create)
    ..aOM<MessageReceiptResponse>(
        17, _omitFieldNames ? '' : 'messageReceiptResponse',
        subBuilder: MessageReceiptResponse.create)
    ..aOM<AddToCartRequest>(20, _omitFieldNames ? '' : 'addToCartRequest',
        subBuilder: AddToCartRequest.create)
    ..aOM<AddToCartResponse>(21, _omitFieldNames ? '' : 'addToCartResponse',
        subBuilder: AddToCartResponse.create)
    ..aOM<RemoveFromCartRequest>(
        22, _omitFieldNames ? '' : 'removeFromCartRequest',
        subBuilder: RemoveFromCartRequest.create)
    ..aOM<RemoveFromCartResponse>(
        23, _omitFieldNames ? '' : 'removeFromCartResponse',
        subBuilder: RemoveFromCartResponse.create)
    ..aOM<ClearCartRequest>(24, _omitFieldNames ? '' : 'clearCartRequest',
        subBuilder: ClearCartRequest.create)
    ..aOM<ClearCartResponse>(25, _omitFieldNames ? '' : 'clearCartResponse',
        subBuilder: ClearCartResponse.create)
    ..aOM<GuidanceCardRequest>(26, _omitFieldNames ? '' : 'guidanceCardRequest',
        subBuilder: GuidanceCardRequest.create)
    ..aOM<GuidanceCardResponse>(
        27, _omitFieldNames ? '' : 'guidanceCardResponse',
        subBuilder: GuidanceCardResponse.create)
    ..aOM<AddPromotionRequest>(28, _omitFieldNames ? '' : 'addPromotionRequest',
        subBuilder: AddPromotionRequest.create)
    ..aOM<AddPromotionResponse>(
        29, _omitFieldNames ? '' : 'addPromotionResponse',
        subBuilder: AddPromotionResponse.create)
    ..aOM<PromotionMessageRequest>(
        30, _omitFieldNames ? '' : 'promotionMessageRequest',
        subBuilder: PromotionMessageRequest.create)
    ..aOM<PromotionMessageResponse>(
        31, _omitFieldNames ? '' : 'promotionMessageResponse',
        subBuilder: PromotionMessageResponse.create)
    ..aOM<ProductMessageRequest>(
        32, _omitFieldNames ? '' : 'productMessageRequest',
        subBuilder: ProductMessageRequest.create)
    ..aOM<ProductMessageResponse>(
        33, _omitFieldNames ? '' : 'productMessageResponse',
        subBuilder: ProductMessageResponse.create)
    ..aOM<ChatStatusRequest>(34, _omitFieldNames ? '' : 'chatStatusRequest',
        subBuilder: ChatStatusRequest.create)
    ..aOM<ChatStatusResponse>(35, _omitFieldNames ? '' : 'chatStatusResponse',
        subBuilder: ChatStatusResponse.create)
    ..aOM<CustomActionRequest>(36, _omitFieldNames ? '' : 'customActionRequest',
        subBuilder: CustomActionRequest.create)
    ..aOM<CustomActionResponse>(
        37, _omitFieldNames ? '' : 'customActionResponse',
        subBuilder: CustomActionResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SdkMessage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SdkMessage copyWith(void Function(SdkMessage) updates) =>
      super.copyWith((message) => updates(message as SdkMessage)) as SdkMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SdkMessage create() => SdkMessage._();
  @$core.override
  SdkMessage createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SdkMessage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SdkMessage>(create);
  static SdkMessage? _defaultInstance;

  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  @$pb.TagNumber(12)
  @$pb.TagNumber(13)
  @$pb.TagNumber(14)
  @$pb.TagNumber(15)
  @$pb.TagNumber(16)
  @$pb.TagNumber(17)
  @$pb.TagNumber(20)
  @$pb.TagNumber(21)
  @$pb.TagNumber(22)
  @$pb.TagNumber(23)
  @$pb.TagNumber(24)
  @$pb.TagNumber(25)
  @$pb.TagNumber(26)
  @$pb.TagNumber(27)
  @$pb.TagNumber(28)
  @$pb.TagNumber(29)
  @$pb.TagNumber(30)
  @$pb.TagNumber(31)
  @$pb.TagNumber(32)
  @$pb.TagNumber(33)
  @$pb.TagNumber(34)
  @$pb.TagNumber(35)
  @$pb.TagNumber(36)
  @$pb.TagNumber(37)
  SdkMessage_Payload whichPayload() =>
      _SdkMessage_PayloadByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  @$pb.TagNumber(12)
  @$pb.TagNumber(13)
  @$pb.TagNumber(14)
  @$pb.TagNumber(15)
  @$pb.TagNumber(16)
  @$pb.TagNumber(17)
  @$pb.TagNumber(20)
  @$pb.TagNumber(21)
  @$pb.TagNumber(22)
  @$pb.TagNumber(23)
  @$pb.TagNumber(24)
  @$pb.TagNumber(25)
  @$pb.TagNumber(26)
  @$pb.TagNumber(27)
  @$pb.TagNumber(28)
  @$pb.TagNumber(29)
  @$pb.TagNumber(30)
  @$pb.TagNumber(31)
  @$pb.TagNumber(32)
  @$pb.TagNumber(33)
  @$pb.TagNumber(34)
  @$pb.TagNumber(35)
  @$pb.TagNumber(36)
  @$pb.TagNumber(37)
  void clearPayload() => $_clearField($_whichOneof(0));

  /// A client-generated id that can be used to correlate requests with responses.
  @$pb.TagNumber(1)
  $core.String get correlationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set correlationId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCorrelationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCorrelationId() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Timestamp get timestamp => $_getN(1);
  @$pb.TagNumber(2)
  set timestamp($0.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestamp() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Timestamp ensureTimestamp() => $_ensure(1);

  /// Bi-directional
  @$pb.TagNumber(10)
  TextMessageRequest get textMessageRequest => $_getN(2);
  @$pb.TagNumber(10)
  set textMessageRequest(TextMessageRequest value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasTextMessageRequest() => $_has(2);
  @$pb.TagNumber(10)
  void clearTextMessageRequest() => $_clearField(10);
  @$pb.TagNumber(10)
  TextMessageRequest ensureTextMessageRequest() => $_ensure(2);

  @$pb.TagNumber(11)
  TextMessageResponse get textMessageResponse => $_getN(3);
  @$pb.TagNumber(11)
  set textMessageResponse(TextMessageResponse value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasTextMessageResponse() => $_has(3);
  @$pb.TagNumber(11)
  void clearTextMessageResponse() => $_clearField(11);
  @$pb.TagNumber(11)
  TextMessageResponse ensureTextMessageResponse() => $_ensure(3);

  @$pb.TagNumber(12)
  VoiceMessageRequest get voiceMessageRequest => $_getN(4);
  @$pb.TagNumber(12)
  set voiceMessageRequest(VoiceMessageRequest value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasVoiceMessageRequest() => $_has(4);
  @$pb.TagNumber(12)
  void clearVoiceMessageRequest() => $_clearField(12);
  @$pb.TagNumber(12)
  VoiceMessageRequest ensureVoiceMessageRequest() => $_ensure(4);

  @$pb.TagNumber(13)
  VoiceMessageResponse get voiceMessageResponse => $_getN(5);
  @$pb.TagNumber(13)
  set voiceMessageResponse(VoiceMessageResponse value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasVoiceMessageResponse() => $_has(5);
  @$pb.TagNumber(13)
  void clearVoiceMessageResponse() => $_clearField(13);
  @$pb.TagNumber(13)
  VoiceMessageResponse ensureVoiceMessageResponse() => $_ensure(5);

  @$pb.TagNumber(14)
  ImageMessageRequest get imageMessageRequest => $_getN(6);
  @$pb.TagNumber(14)
  set imageMessageRequest(ImageMessageRequest value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasImageMessageRequest() => $_has(6);
  @$pb.TagNumber(14)
  void clearImageMessageRequest() => $_clearField(14);
  @$pb.TagNumber(14)
  ImageMessageRequest ensureImageMessageRequest() => $_ensure(6);

  @$pb.TagNumber(15)
  ImageMessageResponse get imageMessageResponse => $_getN(7);
  @$pb.TagNumber(15)
  set imageMessageResponse(ImageMessageResponse value) => $_setField(15, value);
  @$pb.TagNumber(15)
  $core.bool hasImageMessageResponse() => $_has(7);
  @$pb.TagNumber(15)
  void clearImageMessageResponse() => $_clearField(15);
  @$pb.TagNumber(15)
  ImageMessageResponse ensureImageMessageResponse() => $_ensure(7);

  @$pb.TagNumber(16)
  MessageReceiptRequest get messageReceiptRequest => $_getN(8);
  @$pb.TagNumber(16)
  set messageReceiptRequest(MessageReceiptRequest value) =>
      $_setField(16, value);
  @$pb.TagNumber(16)
  $core.bool hasMessageReceiptRequest() => $_has(8);
  @$pb.TagNumber(16)
  void clearMessageReceiptRequest() => $_clearField(16);
  @$pb.TagNumber(16)
  MessageReceiptRequest ensureMessageReceiptRequest() => $_ensure(8);

  @$pb.TagNumber(17)
  MessageReceiptResponse get messageReceiptResponse => $_getN(9);
  @$pb.TagNumber(17)
  set messageReceiptResponse(MessageReceiptResponse value) =>
      $_setField(17, value);
  @$pb.TagNumber(17)
  $core.bool hasMessageReceiptResponse() => $_has(9);
  @$pb.TagNumber(17)
  void clearMessageReceiptResponse() => $_clearField(17);
  @$pb.TagNumber(17)
  MessageReceiptResponse ensureMessageReceiptResponse() => $_ensure(9);

  /// Client → channel
  @$pb.TagNumber(20)
  AddToCartRequest get addToCartRequest => $_getN(10);
  @$pb.TagNumber(20)
  set addToCartRequest(AddToCartRequest value) => $_setField(20, value);
  @$pb.TagNumber(20)
  $core.bool hasAddToCartRequest() => $_has(10);
  @$pb.TagNumber(20)
  void clearAddToCartRequest() => $_clearField(20);
  @$pb.TagNumber(20)
  AddToCartRequest ensureAddToCartRequest() => $_ensure(10);

  @$pb.TagNumber(21)
  AddToCartResponse get addToCartResponse => $_getN(11);
  @$pb.TagNumber(21)
  set addToCartResponse(AddToCartResponse value) => $_setField(21, value);
  @$pb.TagNumber(21)
  $core.bool hasAddToCartResponse() => $_has(11);
  @$pb.TagNumber(21)
  void clearAddToCartResponse() => $_clearField(21);
  @$pb.TagNumber(21)
  AddToCartResponse ensureAddToCartResponse() => $_ensure(11);

  @$pb.TagNumber(22)
  RemoveFromCartRequest get removeFromCartRequest => $_getN(12);
  @$pb.TagNumber(22)
  set removeFromCartRequest(RemoveFromCartRequest value) =>
      $_setField(22, value);
  @$pb.TagNumber(22)
  $core.bool hasRemoveFromCartRequest() => $_has(12);
  @$pb.TagNumber(22)
  void clearRemoveFromCartRequest() => $_clearField(22);
  @$pb.TagNumber(22)
  RemoveFromCartRequest ensureRemoveFromCartRequest() => $_ensure(12);

  @$pb.TagNumber(23)
  RemoveFromCartResponse get removeFromCartResponse => $_getN(13);
  @$pb.TagNumber(23)
  set removeFromCartResponse(RemoveFromCartResponse value) =>
      $_setField(23, value);
  @$pb.TagNumber(23)
  $core.bool hasRemoveFromCartResponse() => $_has(13);
  @$pb.TagNumber(23)
  void clearRemoveFromCartResponse() => $_clearField(23);
  @$pb.TagNumber(23)
  RemoveFromCartResponse ensureRemoveFromCartResponse() => $_ensure(13);

  @$pb.TagNumber(24)
  ClearCartRequest get clearCartRequest => $_getN(14);
  @$pb.TagNumber(24)
  set clearCartRequest(ClearCartRequest value) => $_setField(24, value);
  @$pb.TagNumber(24)
  $core.bool hasClearCartRequest() => $_has(14);
  @$pb.TagNumber(24)
  void clearClearCartRequest() => $_clearField(24);
  @$pb.TagNumber(24)
  ClearCartRequest ensureClearCartRequest() => $_ensure(14);

  @$pb.TagNumber(25)
  ClearCartResponse get clearCartResponse => $_getN(15);
  @$pb.TagNumber(25)
  set clearCartResponse(ClearCartResponse value) => $_setField(25, value);
  @$pb.TagNumber(25)
  $core.bool hasClearCartResponse() => $_has(15);
  @$pb.TagNumber(25)
  void clearClearCartResponse() => $_clearField(25);
  @$pb.TagNumber(25)
  ClearCartResponse ensureClearCartResponse() => $_ensure(15);

  @$pb.TagNumber(26)
  GuidanceCardRequest get guidanceCardRequest => $_getN(16);
  @$pb.TagNumber(26)
  set guidanceCardRequest(GuidanceCardRequest value) => $_setField(26, value);
  @$pb.TagNumber(26)
  $core.bool hasGuidanceCardRequest() => $_has(16);
  @$pb.TagNumber(26)
  void clearGuidanceCardRequest() => $_clearField(26);
  @$pb.TagNumber(26)
  GuidanceCardRequest ensureGuidanceCardRequest() => $_ensure(16);

  @$pb.TagNumber(27)
  GuidanceCardResponse get guidanceCardResponse => $_getN(17);
  @$pb.TagNumber(27)
  set guidanceCardResponse(GuidanceCardResponse value) => $_setField(27, value);
  @$pb.TagNumber(27)
  $core.bool hasGuidanceCardResponse() => $_has(17);
  @$pb.TagNumber(27)
  void clearGuidanceCardResponse() => $_clearField(27);
  @$pb.TagNumber(27)
  GuidanceCardResponse ensureGuidanceCardResponse() => $_ensure(17);

  @$pb.TagNumber(28)
  AddPromotionRequest get addPromotionRequest => $_getN(18);
  @$pb.TagNumber(28)
  set addPromotionRequest(AddPromotionRequest value) => $_setField(28, value);
  @$pb.TagNumber(28)
  $core.bool hasAddPromotionRequest() => $_has(18);
  @$pb.TagNumber(28)
  void clearAddPromotionRequest() => $_clearField(28);
  @$pb.TagNumber(28)
  AddPromotionRequest ensureAddPromotionRequest() => $_ensure(18);

  @$pb.TagNumber(29)
  AddPromotionResponse get addPromotionResponse => $_getN(19);
  @$pb.TagNumber(29)
  set addPromotionResponse(AddPromotionResponse value) => $_setField(29, value);
  @$pb.TagNumber(29)
  $core.bool hasAddPromotionResponse() => $_has(19);
  @$pb.TagNumber(29)
  void clearAddPromotionResponse() => $_clearField(29);
  @$pb.TagNumber(29)
  AddPromotionResponse ensureAddPromotionResponse() => $_ensure(19);

  /// Channel → client
  @$pb.TagNumber(30)
  PromotionMessageRequest get promotionMessageRequest => $_getN(20);
  @$pb.TagNumber(30)
  set promotionMessageRequest(PromotionMessageRequest value) =>
      $_setField(30, value);
  @$pb.TagNumber(30)
  $core.bool hasPromotionMessageRequest() => $_has(20);
  @$pb.TagNumber(30)
  void clearPromotionMessageRequest() => $_clearField(30);
  @$pb.TagNumber(30)
  PromotionMessageRequest ensurePromotionMessageRequest() => $_ensure(20);

  @$pb.TagNumber(31)
  PromotionMessageResponse get promotionMessageResponse => $_getN(21);
  @$pb.TagNumber(31)
  set promotionMessageResponse(PromotionMessageResponse value) =>
      $_setField(31, value);
  @$pb.TagNumber(31)
  $core.bool hasPromotionMessageResponse() => $_has(21);
  @$pb.TagNumber(31)
  void clearPromotionMessageResponse() => $_clearField(31);
  @$pb.TagNumber(31)
  PromotionMessageResponse ensurePromotionMessageResponse() => $_ensure(21);

  @$pb.TagNumber(32)
  ProductMessageRequest get productMessageRequest => $_getN(22);
  @$pb.TagNumber(32)
  set productMessageRequest(ProductMessageRequest value) =>
      $_setField(32, value);
  @$pb.TagNumber(32)
  $core.bool hasProductMessageRequest() => $_has(22);
  @$pb.TagNumber(32)
  void clearProductMessageRequest() => $_clearField(32);
  @$pb.TagNumber(32)
  ProductMessageRequest ensureProductMessageRequest() => $_ensure(22);

  @$pb.TagNumber(33)
  ProductMessageResponse get productMessageResponse => $_getN(23);
  @$pb.TagNumber(33)
  set productMessageResponse(ProductMessageResponse value) =>
      $_setField(33, value);
  @$pb.TagNumber(33)
  $core.bool hasProductMessageResponse() => $_has(23);
  @$pb.TagNumber(33)
  void clearProductMessageResponse() => $_clearField(33);
  @$pb.TagNumber(33)
  ProductMessageResponse ensureProductMessageResponse() => $_ensure(23);

  @$pb.TagNumber(34)
  ChatStatusRequest get chatStatusRequest => $_getN(24);
  @$pb.TagNumber(34)
  set chatStatusRequest(ChatStatusRequest value) => $_setField(34, value);
  @$pb.TagNumber(34)
  $core.bool hasChatStatusRequest() => $_has(24);
  @$pb.TagNumber(34)
  void clearChatStatusRequest() => $_clearField(34);
  @$pb.TagNumber(34)
  ChatStatusRequest ensureChatStatusRequest() => $_ensure(24);

  @$pb.TagNumber(35)
  ChatStatusResponse get chatStatusResponse => $_getN(25);
  @$pb.TagNumber(35)
  set chatStatusResponse(ChatStatusResponse value) => $_setField(35, value);
  @$pb.TagNumber(35)
  $core.bool hasChatStatusResponse() => $_has(25);
  @$pb.TagNumber(35)
  void clearChatStatusResponse() => $_clearField(35);
  @$pb.TagNumber(35)
  ChatStatusResponse ensureChatStatusResponse() => $_ensure(25);

  @$pb.TagNumber(36)
  CustomActionRequest get customActionRequest => $_getN(26);
  @$pb.TagNumber(36)
  set customActionRequest(CustomActionRequest value) => $_setField(36, value);
  @$pb.TagNumber(36)
  $core.bool hasCustomActionRequest() => $_has(26);
  @$pb.TagNumber(36)
  void clearCustomActionRequest() => $_clearField(36);
  @$pb.TagNumber(36)
  CustomActionRequest ensureCustomActionRequest() => $_ensure(26);

  @$pb.TagNumber(37)
  CustomActionResponse get customActionResponse => $_getN(27);
  @$pb.TagNumber(37)
  set customActionResponse(CustomActionResponse value) => $_setField(37, value);
  @$pb.TagNumber(37)
  $core.bool hasCustomActionResponse() => $_has(27);
  @$pb.TagNumber(37)
  void clearCustomActionResponse() => $_clearField(37);
  @$pb.TagNumber(37)
  CustomActionResponse ensureCustomActionResponse() => $_ensure(27);
}

/// TextMessage holds the payload of a plain-text conversation turn.
class TextMessage extends $pb.GeneratedMessage {
  factory TextMessage({
    $core.String? messageId,
    $0.Timestamp? timestamp,
    $core.String? text,
    MessageStatus? status,
    MessageRole? role,
  }) {
    final result = create();
    if (messageId != null) result.messageId = messageId;
    if (timestamp != null) result.timestamp = timestamp;
    if (text != null) result.text = text;
    if (status != null) result.status = status;
    if (role != null) result.role = role;
    return result;
  }

  TextMessage._();

  factory TextMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TextMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TextMessage',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'messageId')
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..aOS(3, _omitFieldNames ? '' : 'text')
    ..aE<MessageStatus>(4, _omitFieldNames ? '' : 'status',
        enumValues: MessageStatus.values)
    ..aE<MessageRole>(5, _omitFieldNames ? '' : 'role',
        enumValues: MessageRole.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TextMessage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TextMessage copyWith(void Function(TextMessage) updates) =>
      super.copyWith((message) => updates(message as TextMessage))
          as TextMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TextMessage create() => TextMessage._();
  @$core.override
  TextMessage createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TextMessage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TextMessage>(create);
  static TextMessage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get messageId => $_getSZ(0);
  @$pb.TagNumber(1)
  set messageId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessageId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessageId() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Timestamp get timestamp => $_getN(1);
  @$pb.TagNumber(2)
  set timestamp($0.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestamp() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Timestamp ensureTimestamp() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.String get text => $_getSZ(2);
  @$pb.TagNumber(3)
  set text($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasText() => $_has(2);
  @$pb.TagNumber(3)
  void clearText() => $_clearField(3);

  @$pb.TagNumber(4)
  MessageStatus get status => $_getN(3);
  @$pb.TagNumber(4)
  set status(MessageStatus value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasStatus() => $_has(3);
  @$pb.TagNumber(4)
  void clearStatus() => $_clearField(4);

  @$pb.TagNumber(5)
  MessageRole get role => $_getN(4);
  @$pb.TagNumber(5)
  set role(MessageRole value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasRole() => $_has(4);
  @$pb.TagNumber(5)
  void clearRole() => $_clearField(5);
}

/// TextMessageRequest is sent by either party to deliver a text message.
class TextMessageRequest extends $pb.GeneratedMessage {
  factory TextMessageRequest({
    TextMessage? content,
    $0.Timestamp? timestamp,
  }) {
    final result = create();
    if (content != null) result.content = content;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  TextMessageRequest._();

  factory TextMessageRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TextMessageRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TextMessageRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v1'),
      createEmptyInstance: create)
    ..aOM<TextMessage>(1, _omitFieldNames ? '' : 'content',
        subBuilder: TextMessage.create)
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TextMessageRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TextMessageRequest copyWith(void Function(TextMessageRequest) updates) =>
      super.copyWith((message) => updates(message as TextMessageRequest))
          as TextMessageRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TextMessageRequest create() => TextMessageRequest._();
  @$core.override
  TextMessageRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TextMessageRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TextMessageRequest>(create);
  static TextMessageRequest? _defaultInstance;

  @$pb.TagNumber(1)
  TextMessage get content => $_getN(0);
  @$pb.TagNumber(1)
  set content(TextMessage value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasContent() => $_has(0);
  @$pb.TagNumber(1)
  void clearContent() => $_clearField(1);
  @$pb.TagNumber(1)
  TextMessage ensureContent() => $_ensure(0);

  @$pb.TagNumber(2)
  $0.Timestamp get timestamp => $_getN(1);
  @$pb.TagNumber(2)
  set timestamp($0.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestamp() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Timestamp ensureTimestamp() => $_ensure(1);
}

/// TextMessageResponse acknowledges a TextMessageRequest and returns the assigned message id.
class TextMessageResponse extends $pb.GeneratedMessage {
  factory TextMessageResponse({
    ResponseStatus? status,
    $0.Timestamp? timestamp,
    $core.String? messageId,
  }) {
    final result = create();
    if (status != null) result.status = status;
    if (timestamp != null) result.timestamp = timestamp;
    if (messageId != null) result.messageId = messageId;
    return result;
  }

  TextMessageResponse._();

  factory TextMessageResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TextMessageResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TextMessageResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v1'),
      createEmptyInstance: create)
    ..aE<ResponseStatus>(1, _omitFieldNames ? '' : 'status',
        enumValues: ResponseStatus.values)
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..aOS(3, _omitFieldNames ? '' : 'messageId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TextMessageResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TextMessageResponse copyWith(void Function(TextMessageResponse) updates) =>
      super.copyWith((message) => updates(message as TextMessageResponse))
          as TextMessageResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TextMessageResponse create() => TextMessageResponse._();
  @$core.override
  TextMessageResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TextMessageResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TextMessageResponse>(create);
  static TextMessageResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ResponseStatus get status => $_getN(0);
  @$pb.TagNumber(1)
  set status(ResponseStatus value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Timestamp get timestamp => $_getN(1);
  @$pb.TagNumber(2)
  set timestamp($0.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestamp() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Timestamp ensureTimestamp() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.String get messageId => $_getSZ(2);
  @$pb.TagNumber(3)
  set messageId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMessageId() => $_has(2);
  @$pb.TagNumber(3)
  void clearMessageId() => $_clearField(3);
}

/// VoiceMessage holds the payload of a voice-note conversation turn.
class VoiceMessage extends $pb.GeneratedMessage {
  factory VoiceMessage({
    $core.String? messageId,
    $0.Timestamp? timestamp,
    $core.String? mediaUrl,
    $core.Iterable<$core.double>? amplitudesPreview,
    $core.double? duration,
    $core.String? mediaType,
    MessageStatus? status,
    MessageRole? role,
  }) {
    final result = create();
    if (messageId != null) result.messageId = messageId;
    if (timestamp != null) result.timestamp = timestamp;
    if (mediaUrl != null) result.mediaUrl = mediaUrl;
    if (amplitudesPreview != null)
      result.amplitudesPreview.addAll(amplitudesPreview);
    if (duration != null) result.duration = duration;
    if (mediaType != null) result.mediaType = mediaType;
    if (status != null) result.status = status;
    if (role != null) result.role = role;
    return result;
  }

  VoiceMessage._();

  factory VoiceMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory VoiceMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'VoiceMessage',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'messageId')
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..aOS(3, _omitFieldNames ? '' : 'mediaUrl')
    ..p<$core.double>(
        4, _omitFieldNames ? '' : 'amplitudesPreview', $pb.PbFieldType.KF)
    ..aD(5, _omitFieldNames ? '' : 'duration')
    ..aOS(6, _omitFieldNames ? '' : 'mediaType')
    ..aE<MessageStatus>(7, _omitFieldNames ? '' : 'status',
        enumValues: MessageStatus.values)
    ..aE<MessageRole>(8, _omitFieldNames ? '' : 'role',
        enumValues: MessageRole.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VoiceMessage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VoiceMessage copyWith(void Function(VoiceMessage) updates) =>
      super.copyWith((message) => updates(message as VoiceMessage))
          as VoiceMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VoiceMessage create() => VoiceMessage._();
  @$core.override
  VoiceMessage createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static VoiceMessage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<VoiceMessage>(create);
  static VoiceMessage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get messageId => $_getSZ(0);
  @$pb.TagNumber(1)
  set messageId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessageId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessageId() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Timestamp get timestamp => $_getN(1);
  @$pb.TagNumber(2)
  set timestamp($0.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestamp() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Timestamp ensureTimestamp() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.String get mediaUrl => $_getSZ(2);
  @$pb.TagNumber(3)
  set mediaUrl($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMediaUrl() => $_has(2);
  @$pb.TagNumber(3)
  void clearMediaUrl() => $_clearField(3);

  /// Amplitude samples used to render the waveform preview in the UI.
  @$pb.TagNumber(4)
  $pb.PbList<$core.double> get amplitudesPreview => $_getList(3);

  @$pb.TagNumber(5)
  $core.double get duration => $_getN(4);
  @$pb.TagNumber(5)
  set duration($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDuration() => $_has(4);
  @$pb.TagNumber(5)
  void clearDuration() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get mediaType => $_getSZ(5);
  @$pb.TagNumber(6)
  set mediaType($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMediaType() => $_has(5);
  @$pb.TagNumber(6)
  void clearMediaType() => $_clearField(6);

  @$pb.TagNumber(7)
  MessageStatus get status => $_getN(6);
  @$pb.TagNumber(7)
  set status(MessageStatus value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasStatus() => $_has(6);
  @$pb.TagNumber(7)
  void clearStatus() => $_clearField(7);

  @$pb.TagNumber(8)
  MessageRole get role => $_getN(7);
  @$pb.TagNumber(8)
  set role(MessageRole value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasRole() => $_has(7);
  @$pb.TagNumber(8)
  void clearRole() => $_clearField(8);
}

/// VoiceMessageRequest is sent by either party to deliver a voice note.
class VoiceMessageRequest extends $pb.GeneratedMessage {
  factory VoiceMessageRequest({
    VoiceMessage? content,
    $0.Timestamp? timestamp,
    $core.Iterable<$core.String>? quickReplies,
  }) {
    final result = create();
    if (content != null) result.content = content;
    if (timestamp != null) result.timestamp = timestamp;
    if (quickReplies != null) result.quickReplies.addAll(quickReplies);
    return result;
  }

  VoiceMessageRequest._();

  factory VoiceMessageRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory VoiceMessageRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'VoiceMessageRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v1'),
      createEmptyInstance: create)
    ..aOM<VoiceMessage>(1, _omitFieldNames ? '' : 'content',
        subBuilder: VoiceMessage.create)
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..pPS(3, _omitFieldNames ? '' : 'quickReplies')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VoiceMessageRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VoiceMessageRequest copyWith(void Function(VoiceMessageRequest) updates) =>
      super.copyWith((message) => updates(message as VoiceMessageRequest))
          as VoiceMessageRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VoiceMessageRequest create() => VoiceMessageRequest._();
  @$core.override
  VoiceMessageRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static VoiceMessageRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<VoiceMessageRequest>(create);
  static VoiceMessageRequest? _defaultInstance;

  @$pb.TagNumber(1)
  VoiceMessage get content => $_getN(0);
  @$pb.TagNumber(1)
  set content(VoiceMessage value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasContent() => $_has(0);
  @$pb.TagNumber(1)
  void clearContent() => $_clearField(1);
  @$pb.TagNumber(1)
  VoiceMessage ensureContent() => $_ensure(0);

  @$pb.TagNumber(2)
  $0.Timestamp get timestamp => $_getN(1);
  @$pb.TagNumber(2)
  set timestamp($0.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestamp() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Timestamp ensureTimestamp() => $_ensure(1);

  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get quickReplies => $_getList(2);
}

/// VoiceMessageResponse acknowledges a VoiceMessageRequest and returns the assigned message id.
class VoiceMessageResponse extends $pb.GeneratedMessage {
  factory VoiceMessageResponse({
    ResponseStatus? status,
    $0.Timestamp? timestamp,
    $core.String? messageId,
  }) {
    final result = create();
    if (status != null) result.status = status;
    if (timestamp != null) result.timestamp = timestamp;
    if (messageId != null) result.messageId = messageId;
    return result;
  }

  VoiceMessageResponse._();

  factory VoiceMessageResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory VoiceMessageResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'VoiceMessageResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v1'),
      createEmptyInstance: create)
    ..aE<ResponseStatus>(1, _omitFieldNames ? '' : 'status',
        enumValues: ResponseStatus.values)
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..aOS(3, _omitFieldNames ? '' : 'messageId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VoiceMessageResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VoiceMessageResponse copyWith(void Function(VoiceMessageResponse) updates) =>
      super.copyWith((message) => updates(message as VoiceMessageResponse))
          as VoiceMessageResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VoiceMessageResponse create() => VoiceMessageResponse._();
  @$core.override
  VoiceMessageResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static VoiceMessageResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<VoiceMessageResponse>(create);
  static VoiceMessageResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ResponseStatus get status => $_getN(0);
  @$pb.TagNumber(1)
  set status(ResponseStatus value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Timestamp get timestamp => $_getN(1);
  @$pb.TagNumber(2)
  set timestamp($0.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestamp() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Timestamp ensureTimestamp() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.String get messageId => $_getSZ(2);
  @$pb.TagNumber(3)
  set messageId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMessageId() => $_has(2);
  @$pb.TagNumber(3)
  void clearMessageId() => $_clearField(3);
}

/// ImageMessage holds the payload of an image conversation turn.
class ImageMessage extends $pb.GeneratedMessage {
  factory ImageMessage({
    $core.String? messageId,
    $0.Timestamp? timestamp,
    $core.String? text,
    $core.String? mediaUrl,
    $core.String? mediaType,
    MessageStatus? status,
    MessageRole? role,
  }) {
    final result = create();
    if (messageId != null) result.messageId = messageId;
    if (timestamp != null) result.timestamp = timestamp;
    if (text != null) result.text = text;
    if (mediaUrl != null) result.mediaUrl = mediaUrl;
    if (mediaType != null) result.mediaType = mediaType;
    if (status != null) result.status = status;
    if (role != null) result.role = role;
    return result;
  }

  ImageMessage._();

  factory ImageMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ImageMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ImageMessage',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'messageId')
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..aOS(3, _omitFieldNames ? '' : 'text')
    ..aOS(4, _omitFieldNames ? '' : 'mediaUrl')
    ..aOS(5, _omitFieldNames ? '' : 'mediaType')
    ..aE<MessageStatus>(6, _omitFieldNames ? '' : 'status',
        enumValues: MessageStatus.values)
    ..aE<MessageRole>(7, _omitFieldNames ? '' : 'role',
        enumValues: MessageRole.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImageMessage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImageMessage copyWith(void Function(ImageMessage) updates) =>
      super.copyWith((message) => updates(message as ImageMessage))
          as ImageMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImageMessage create() => ImageMessage._();
  @$core.override
  ImageMessage createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ImageMessage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ImageMessage>(create);
  static ImageMessage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get messageId => $_getSZ(0);
  @$pb.TagNumber(1)
  set messageId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessageId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessageId() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Timestamp get timestamp => $_getN(1);
  @$pb.TagNumber(2)
  set timestamp($0.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestamp() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Timestamp ensureTimestamp() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.String get text => $_getSZ(2);
  @$pb.TagNumber(3)
  set text($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasText() => $_has(2);
  @$pb.TagNumber(3)
  void clearText() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get mediaUrl => $_getSZ(3);
  @$pb.TagNumber(4)
  set mediaUrl($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMediaUrl() => $_has(3);
  @$pb.TagNumber(4)
  void clearMediaUrl() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get mediaType => $_getSZ(4);
  @$pb.TagNumber(5)
  set mediaType($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMediaType() => $_has(4);
  @$pb.TagNumber(5)
  void clearMediaType() => $_clearField(5);

  @$pb.TagNumber(6)
  MessageStatus get status => $_getN(5);
  @$pb.TagNumber(6)
  set status(MessageStatus value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasStatus() => $_has(5);
  @$pb.TagNumber(6)
  void clearStatus() => $_clearField(6);

  @$pb.TagNumber(7)
  MessageRole get role => $_getN(6);
  @$pb.TagNumber(7)
  set role(MessageRole value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasRole() => $_has(6);
  @$pb.TagNumber(7)
  void clearRole() => $_clearField(7);
}

/// ImageMessageRequest is sent by either party to deliver an image.
class ImageMessageRequest extends $pb.GeneratedMessage {
  factory ImageMessageRequest({
    ImageMessage? content,
    $0.Timestamp? timestamp,
    $core.Iterable<$core.String>? quickReplies,
  }) {
    final result = create();
    if (content != null) result.content = content;
    if (timestamp != null) result.timestamp = timestamp;
    if (quickReplies != null) result.quickReplies.addAll(quickReplies);
    return result;
  }

  ImageMessageRequest._();

  factory ImageMessageRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ImageMessageRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ImageMessageRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v1'),
      createEmptyInstance: create)
    ..aOM<ImageMessage>(1, _omitFieldNames ? '' : 'content',
        subBuilder: ImageMessage.create)
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..pPS(3, _omitFieldNames ? '' : 'quickReplies')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImageMessageRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImageMessageRequest copyWith(void Function(ImageMessageRequest) updates) =>
      super.copyWith((message) => updates(message as ImageMessageRequest))
          as ImageMessageRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImageMessageRequest create() => ImageMessageRequest._();
  @$core.override
  ImageMessageRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ImageMessageRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ImageMessageRequest>(create);
  static ImageMessageRequest? _defaultInstance;

  @$pb.TagNumber(1)
  ImageMessage get content => $_getN(0);
  @$pb.TagNumber(1)
  set content(ImageMessage value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasContent() => $_has(0);
  @$pb.TagNumber(1)
  void clearContent() => $_clearField(1);
  @$pb.TagNumber(1)
  ImageMessage ensureContent() => $_ensure(0);

  @$pb.TagNumber(2)
  $0.Timestamp get timestamp => $_getN(1);
  @$pb.TagNumber(2)
  set timestamp($0.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestamp() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Timestamp ensureTimestamp() => $_ensure(1);

  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get quickReplies => $_getList(2);
}

/// ImageMessageResponse acknowledges an ImageMessageRequest and returns the assigned message id.
class ImageMessageResponse extends $pb.GeneratedMessage {
  factory ImageMessageResponse({
    ResponseStatus? status,
    $0.Timestamp? timestamp,
    $core.String? messageId,
  }) {
    final result = create();
    if (status != null) result.status = status;
    if (timestamp != null) result.timestamp = timestamp;
    if (messageId != null) result.messageId = messageId;
    return result;
  }

  ImageMessageResponse._();

  factory ImageMessageResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ImageMessageResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ImageMessageResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v1'),
      createEmptyInstance: create)
    ..aE<ResponseStatus>(1, _omitFieldNames ? '' : 'status',
        enumValues: ResponseStatus.values)
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..aOS(3, _omitFieldNames ? '' : 'messageId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImageMessageResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImageMessageResponse copyWith(void Function(ImageMessageResponse) updates) =>
      super.copyWith((message) => updates(message as ImageMessageResponse))
          as ImageMessageResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImageMessageResponse create() => ImageMessageResponse._();
  @$core.override
  ImageMessageResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ImageMessageResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ImageMessageResponse>(create);
  static ImageMessageResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ResponseStatus get status => $_getN(0);
  @$pb.TagNumber(1)
  set status(ResponseStatus value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Timestamp get timestamp => $_getN(1);
  @$pb.TagNumber(2)
  set timestamp($0.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestamp() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Timestamp ensureTimestamp() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.String get messageId => $_getSZ(2);
  @$pb.TagNumber(3)
  set messageId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMessageId() => $_has(2);
  @$pb.TagNumber(3)
  void clearMessageId() => $_clearField(3);
}

/// MessageReceiptRequest notifies the other party of a message status change.
class MessageReceiptRequest extends $pb.GeneratedMessage {
  factory MessageReceiptRequest({
    MessageStatus? status,
    $core.String? messageId,
    $0.Timestamp? timestamp,
    $core.Iterable<$core.String>? quickReplies,
  }) {
    final result = create();
    if (status != null) result.status = status;
    if (messageId != null) result.messageId = messageId;
    if (timestamp != null) result.timestamp = timestamp;
    if (quickReplies != null) result.quickReplies.addAll(quickReplies);
    return result;
  }

  MessageReceiptRequest._();

  factory MessageReceiptRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MessageReceiptRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MessageReceiptRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v1'),
      createEmptyInstance: create)
    ..aE<MessageStatus>(1, _omitFieldNames ? '' : 'status',
        enumValues: MessageStatus.values)
    ..aOS(2, _omitFieldNames ? '' : 'messageId')
    ..aOM<$0.Timestamp>(3, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..pPS(4, _omitFieldNames ? '' : 'quickReplies')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageReceiptRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageReceiptRequest copyWith(
          void Function(MessageReceiptRequest) updates) =>
      super.copyWith((message) => updates(message as MessageReceiptRequest))
          as MessageReceiptRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MessageReceiptRequest create() => MessageReceiptRequest._();
  @$core.override
  MessageReceiptRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MessageReceiptRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MessageReceiptRequest>(create);
  static MessageReceiptRequest? _defaultInstance;

  @$pb.TagNumber(1)
  MessageStatus get status => $_getN(0);
  @$pb.TagNumber(1)
  set status(MessageStatus value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get messageId => $_getSZ(1);
  @$pb.TagNumber(2)
  set messageId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessageId() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessageId() => $_clearField(2);

  @$pb.TagNumber(3)
  $0.Timestamp get timestamp => $_getN(2);
  @$pb.TagNumber(3)
  set timestamp($0.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasTimestamp() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimestamp() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.Timestamp ensureTimestamp() => $_ensure(2);

  @$pb.TagNumber(4)
  $pb.PbList<$core.String> get quickReplies => $_getList(3);
}

/// MessageReceiptResponse acknowledges a MessageReceiptRequest.
class MessageReceiptResponse extends $pb.GeneratedMessage {
  factory MessageReceiptResponse({
    ResponseStatus? status,
    $0.Timestamp? timestamp,
  }) {
    final result = create();
    if (status != null) result.status = status;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  MessageReceiptResponse._();

  factory MessageReceiptResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MessageReceiptResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MessageReceiptResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v1'),
      createEmptyInstance: create)
    ..aE<ResponseStatus>(1, _omitFieldNames ? '' : 'status',
        enumValues: ResponseStatus.values)
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageReceiptResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MessageReceiptResponse copyWith(
          void Function(MessageReceiptResponse) updates) =>
      super.copyWith((message) => updates(message as MessageReceiptResponse))
          as MessageReceiptResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MessageReceiptResponse create() => MessageReceiptResponse._();
  @$core.override
  MessageReceiptResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MessageReceiptResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MessageReceiptResponse>(create);
  static MessageReceiptResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ResponseStatus get status => $_getN(0);
  @$pb.TagNumber(1)
  set status(ResponseStatus value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Timestamp get timestamp => $_getN(1);
  @$pb.TagNumber(2)
  set timestamp($0.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestamp() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Timestamp ensureTimestamp() => $_ensure(1);
}

/// AddToCartRequest asks the channel to add a SKU to the active cart.
class AddToCartRequest extends $pb.GeneratedMessage {
  factory AddToCartRequest({
    $core.String? sku,
    $0.Timestamp? timestamp,
    $core.double? quantity,
  }) {
    final result = create();
    if (sku != null) result.sku = sku;
    if (timestamp != null) result.timestamp = timestamp;
    if (quantity != null) result.quantity = quantity;
    return result;
  }

  AddToCartRequest._();

  factory AddToCartRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddToCartRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddToCartRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sku')
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..aD(3, _omitFieldNames ? '' : 'quantity')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddToCartRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddToCartRequest copyWith(void Function(AddToCartRequest) updates) =>
      super.copyWith((message) => updates(message as AddToCartRequest))
          as AddToCartRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddToCartRequest create() => AddToCartRequest._();
  @$core.override
  AddToCartRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddToCartRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddToCartRequest>(create);
  static AddToCartRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sku => $_getSZ(0);
  @$pb.TagNumber(1)
  set sku($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSku() => $_has(0);
  @$pb.TagNumber(1)
  void clearSku() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Timestamp get timestamp => $_getN(1);
  @$pb.TagNumber(2)
  set timestamp($0.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestamp() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Timestamp ensureTimestamp() => $_ensure(1);

  /// Double because some clients need fractional quantities (e.g. FEMSA).
  @$pb.TagNumber(3)
  $core.double get quantity => $_getN(2);
  @$pb.TagNumber(3)
  set quantity($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasQuantity() => $_has(2);
  @$pb.TagNumber(3)
  void clearQuantity() => $_clearField(3);
}

/// AddToCartResponse acknowledges an AddToCartRequest.
class AddToCartResponse extends $pb.GeneratedMessage {
  factory AddToCartResponse({
    ResponseStatus? status,
    $0.Timestamp? timestamp,
  }) {
    final result = create();
    if (status != null) result.status = status;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  AddToCartResponse._();

  factory AddToCartResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddToCartResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddToCartResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v1'),
      createEmptyInstance: create)
    ..aE<ResponseStatus>(1, _omitFieldNames ? '' : 'status',
        enumValues: ResponseStatus.values)
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddToCartResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddToCartResponse copyWith(void Function(AddToCartResponse) updates) =>
      super.copyWith((message) => updates(message as AddToCartResponse))
          as AddToCartResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddToCartResponse create() => AddToCartResponse._();
  @$core.override
  AddToCartResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddToCartResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddToCartResponse>(create);
  static AddToCartResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ResponseStatus get status => $_getN(0);
  @$pb.TagNumber(1)
  set status(ResponseStatus value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Timestamp get timestamp => $_getN(1);
  @$pb.TagNumber(2)
  set timestamp($0.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestamp() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Timestamp ensureTimestamp() => $_ensure(1);
}

/// RemoveFromCartRequest asks the channel to remove a SKU from the active cart.
class RemoveFromCartRequest extends $pb.GeneratedMessage {
  factory RemoveFromCartRequest({
    $core.String? sku,
    $0.Timestamp? timestamp,
    $core.double? quantity,
  }) {
    final result = create();
    if (sku != null) result.sku = sku;
    if (timestamp != null) result.timestamp = timestamp;
    if (quantity != null) result.quantity = quantity;
    return result;
  }

  RemoveFromCartRequest._();

  factory RemoveFromCartRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RemoveFromCartRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RemoveFromCartRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sku')
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..aD(3, _omitFieldNames ? '' : 'quantity')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveFromCartRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveFromCartRequest copyWith(
          void Function(RemoveFromCartRequest) updates) =>
      super.copyWith((message) => updates(message as RemoveFromCartRequest))
          as RemoveFromCartRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RemoveFromCartRequest create() => RemoveFromCartRequest._();
  @$core.override
  RemoveFromCartRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RemoveFromCartRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RemoveFromCartRequest>(create);
  static RemoveFromCartRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sku => $_getSZ(0);
  @$pb.TagNumber(1)
  set sku($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSku() => $_has(0);
  @$pb.TagNumber(1)
  void clearSku() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Timestamp get timestamp => $_getN(1);
  @$pb.TagNumber(2)
  set timestamp($0.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestamp() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Timestamp ensureTimestamp() => $_ensure(1);

  /// If omitted the entire SKU line is removed from the cart.
  @$pb.TagNumber(3)
  $core.double get quantity => $_getN(2);
  @$pb.TagNumber(3)
  set quantity($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasQuantity() => $_has(2);
  @$pb.TagNumber(3)
  void clearQuantity() => $_clearField(3);
}

/// RemoveFromCartResponse acknowledges a RemoveFromCartRequest.
class RemoveFromCartResponse extends $pb.GeneratedMessage {
  factory RemoveFromCartResponse({
    ResponseStatus? status,
    $0.Timestamp? timestamp,
  }) {
    final result = create();
    if (status != null) result.status = status;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  RemoveFromCartResponse._();

  factory RemoveFromCartResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RemoveFromCartResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RemoveFromCartResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v1'),
      createEmptyInstance: create)
    ..aE<ResponseStatus>(1, _omitFieldNames ? '' : 'status',
        enumValues: ResponseStatus.values)
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveFromCartResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveFromCartResponse copyWith(
          void Function(RemoveFromCartResponse) updates) =>
      super.copyWith((message) => updates(message as RemoveFromCartResponse))
          as RemoveFromCartResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RemoveFromCartResponse create() => RemoveFromCartResponse._();
  @$core.override
  RemoveFromCartResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RemoveFromCartResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RemoveFromCartResponse>(create);
  static RemoveFromCartResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ResponseStatus get status => $_getN(0);
  @$pb.TagNumber(1)
  set status(ResponseStatus value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Timestamp get timestamp => $_getN(1);
  @$pb.TagNumber(2)
  set timestamp($0.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestamp() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Timestamp ensureTimestamp() => $_ensure(1);
}

/// ClearCartRequest asks the channel to empty the active cart entirely.
class ClearCartRequest extends $pb.GeneratedMessage {
  factory ClearCartRequest({
    $0.Timestamp? timestamp,
  }) {
    final result = create();
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  ClearCartRequest._();

  factory ClearCartRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ClearCartRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClearCartRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v1'),
      createEmptyInstance: create)
    ..aOM<$0.Timestamp>(1, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClearCartRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClearCartRequest copyWith(void Function(ClearCartRequest) updates) =>
      super.copyWith((message) => updates(message as ClearCartRequest))
          as ClearCartRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClearCartRequest create() => ClearCartRequest._();
  @$core.override
  ClearCartRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ClearCartRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClearCartRequest>(create);
  static ClearCartRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Timestamp get timestamp => $_getN(0);
  @$pb.TagNumber(1)
  set timestamp($0.Timestamp value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTimestamp() => $_has(0);
  @$pb.TagNumber(1)
  void clearTimestamp() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Timestamp ensureTimestamp() => $_ensure(0);
}

/// ClearCartResponse acknowledges a ClearCartRequest.
class ClearCartResponse extends $pb.GeneratedMessage {
  factory ClearCartResponse({
    ResponseStatus? status,
    $0.Timestamp? timestamp,
  }) {
    final result = create();
    if (status != null) result.status = status;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  ClearCartResponse._();

  factory ClearCartResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ClearCartResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClearCartResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v1'),
      createEmptyInstance: create)
    ..aE<ResponseStatus>(1, _omitFieldNames ? '' : 'status',
        enumValues: ResponseStatus.values)
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClearCartResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClearCartResponse copyWith(void Function(ClearCartResponse) updates) =>
      super.copyWith((message) => updates(message as ClearCartResponse))
          as ClearCartResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClearCartResponse create() => ClearCartResponse._();
  @$core.override
  ClearCartResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ClearCartResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClearCartResponse>(create);
  static ClearCartResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ResponseStatus get status => $_getN(0);
  @$pb.TagNumber(1)
  set status(ResponseStatus value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Timestamp get timestamp => $_getN(1);
  @$pb.TagNumber(2)
  set timestamp($0.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestamp() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Timestamp ensureTimestamp() => $_ensure(1);
}

/// GuidanceCardRequest asks the channel to return the current guidance cards.
class GuidanceCardRequest extends $pb.GeneratedMessage {
  factory GuidanceCardRequest({
    $0.Timestamp? timestamp,
  }) {
    final result = create();
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  GuidanceCardRequest._();

  factory GuidanceCardRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GuidanceCardRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GuidanceCardRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v1'),
      createEmptyInstance: create)
    ..aOM<$0.Timestamp>(1, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GuidanceCardRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GuidanceCardRequest copyWith(void Function(GuidanceCardRequest) updates) =>
      super.copyWith((message) => updates(message as GuidanceCardRequest))
          as GuidanceCardRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GuidanceCardRequest create() => GuidanceCardRequest._();
  @$core.override
  GuidanceCardRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GuidanceCardRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GuidanceCardRequest>(create);
  static GuidanceCardRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Timestamp get timestamp => $_getN(0);
  @$pb.TagNumber(1)
  set timestamp($0.Timestamp value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTimestamp() => $_has(0);
  @$pb.TagNumber(1)
  void clearTimestamp() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Timestamp ensureTimestamp() => $_ensure(0);
}

/// GuidanceCardResponse returns the guidance cards to display to the user.
class GuidanceCardResponse extends $pb.GeneratedMessage {
  factory GuidanceCardResponse({
    ResponseStatus? status,
    $0.Timestamp? timestamp,
    $core.String? guidanceTitle,
    $core.String? guidanceDescription,
    $core.Iterable<$core.String>? guidanceCards,
  }) {
    final result = create();
    if (status != null) result.status = status;
    if (timestamp != null) result.timestamp = timestamp;
    if (guidanceTitle != null) result.guidanceTitle = guidanceTitle;
    if (guidanceDescription != null)
      result.guidanceDescription = guidanceDescription;
    if (guidanceCards != null) result.guidanceCards.addAll(guidanceCards);
    return result;
  }

  GuidanceCardResponse._();

  factory GuidanceCardResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GuidanceCardResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GuidanceCardResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v1'),
      createEmptyInstance: create)
    ..aE<ResponseStatus>(1, _omitFieldNames ? '' : 'status',
        enumValues: ResponseStatus.values)
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..aOS(3, _omitFieldNames ? '' : 'guidanceTitle')
    ..aOS(4, _omitFieldNames ? '' : 'guidanceDescription')
    ..pPS(5, _omitFieldNames ? '' : 'guidanceCards')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GuidanceCardResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GuidanceCardResponse copyWith(void Function(GuidanceCardResponse) updates) =>
      super.copyWith((message) => updates(message as GuidanceCardResponse))
          as GuidanceCardResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GuidanceCardResponse create() => GuidanceCardResponse._();
  @$core.override
  GuidanceCardResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GuidanceCardResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GuidanceCardResponse>(create);
  static GuidanceCardResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ResponseStatus get status => $_getN(0);
  @$pb.TagNumber(1)
  set status(ResponseStatus value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Timestamp get timestamp => $_getN(1);
  @$pb.TagNumber(2)
  set timestamp($0.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestamp() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Timestamp ensureTimestamp() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.String get guidanceTitle => $_getSZ(2);
  @$pb.TagNumber(3)
  set guidanceTitle($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasGuidanceTitle() => $_has(2);
  @$pb.TagNumber(3)
  void clearGuidanceTitle() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get guidanceDescription => $_getSZ(3);
  @$pb.TagNumber(4)
  set guidanceDescription($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasGuidanceDescription() => $_has(3);
  @$pb.TagNumber(4)
  void clearGuidanceDescription() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<$core.String> get guidanceCards => $_getList(4);
}

/// AddPromotionRequest asks the channel to apply a promotion to the active cart.
class AddPromotionRequest extends $pb.GeneratedMessage {
  factory AddPromotionRequest({
    $core.String? promotionId,
    $0.Timestamp? timestamp,
  }) {
    final result = create();
    if (promotionId != null) result.promotionId = promotionId;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  AddPromotionRequest._();

  factory AddPromotionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddPromotionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddPromotionRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'promotionId')
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddPromotionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddPromotionRequest copyWith(void Function(AddPromotionRequest) updates) =>
      super.copyWith((message) => updates(message as AddPromotionRequest))
          as AddPromotionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddPromotionRequest create() => AddPromotionRequest._();
  @$core.override
  AddPromotionRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddPromotionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddPromotionRequest>(create);
  static AddPromotionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get promotionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set promotionId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPromotionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPromotionId() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Timestamp get timestamp => $_getN(1);
  @$pb.TagNumber(2)
  set timestamp($0.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestamp() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Timestamp ensureTimestamp() => $_ensure(1);
}

/// AddPromotionResponse acknowledges an AddPromotionRequest.
class AddPromotionResponse extends $pb.GeneratedMessage {
  factory AddPromotionResponse({
    ResponseStatus? status,
    $0.Timestamp? timestamp,
  }) {
    final result = create();
    if (status != null) result.status = status;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  AddPromotionResponse._();

  factory AddPromotionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddPromotionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddPromotionResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v1'),
      createEmptyInstance: create)
    ..aE<ResponseStatus>(1, _omitFieldNames ? '' : 'status',
        enumValues: ResponseStatus.values)
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddPromotionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddPromotionResponse copyWith(void Function(AddPromotionResponse) updates) =>
      super.copyWith((message) => updates(message as AddPromotionResponse))
          as AddPromotionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddPromotionResponse create() => AddPromotionResponse._();
  @$core.override
  AddPromotionResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddPromotionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddPromotionResponse>(create);
  static AddPromotionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ResponseStatus get status => $_getN(0);
  @$pb.TagNumber(1)
  set status(ResponseStatus value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Timestamp get timestamp => $_getN(1);
  @$pb.TagNumber(2)
  set timestamp($0.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestamp() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Timestamp ensureTimestamp() => $_ensure(1);
}

/// PromotionMessageRequest delivers a promotional offer to the client UI.
class PromotionMessageRequest extends $pb.GeneratedMessage {
  factory PromotionMessageRequest({
    $core.String? promotionId,
    $core.String? title,
    $core.String? gain,
    $core.String? description,
    $core.String? imageUrl,
    $core.String? footer,
    $0.Timestamp? timestamp,
  }) {
    final result = create();
    if (promotionId != null) result.promotionId = promotionId;
    if (title != null) result.title = title;
    if (gain != null) result.gain = gain;
    if (description != null) result.description = description;
    if (imageUrl != null) result.imageUrl = imageUrl;
    if (footer != null) result.footer = footer;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  PromotionMessageRequest._();

  factory PromotionMessageRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PromotionMessageRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PromotionMessageRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'promotionId')
    ..aOS(2, _omitFieldNames ? '' : 'title')
    ..aOS(3, _omitFieldNames ? '' : 'gain')
    ..aOS(4, _omitFieldNames ? '' : 'description')
    ..aOS(5, _omitFieldNames ? '' : 'imageUrl')
    ..aOS(6, _omitFieldNames ? '' : 'footer')
    ..aOM<$0.Timestamp>(7, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PromotionMessageRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PromotionMessageRequest copyWith(
          void Function(PromotionMessageRequest) updates) =>
      super.copyWith((message) => updates(message as PromotionMessageRequest))
          as PromotionMessageRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PromotionMessageRequest create() => PromotionMessageRequest._();
  @$core.override
  PromotionMessageRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PromotionMessageRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PromotionMessageRequest>(create);
  static PromotionMessageRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get promotionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set promotionId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPromotionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPromotionId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get title => $_getSZ(1);
  @$pb.TagNumber(2)
  set title($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTitle() => $_has(1);
  @$pb.TagNumber(2)
  void clearTitle() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get gain => $_getSZ(2);
  @$pb.TagNumber(3)
  set gain($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasGain() => $_has(2);
  @$pb.TagNumber(3)
  void clearGain() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get description => $_getSZ(3);
  @$pb.TagNumber(4)
  set description($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDescription() => $_has(3);
  @$pb.TagNumber(4)
  void clearDescription() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get imageUrl => $_getSZ(4);
  @$pb.TagNumber(5)
  set imageUrl($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasImageUrl() => $_has(4);
  @$pb.TagNumber(5)
  void clearImageUrl() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get footer => $_getSZ(5);
  @$pb.TagNumber(6)
  set footer($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasFooter() => $_has(5);
  @$pb.TagNumber(6)
  void clearFooter() => $_clearField(6);

  @$pb.TagNumber(7)
  $0.Timestamp get timestamp => $_getN(6);
  @$pb.TagNumber(7)
  set timestamp($0.Timestamp value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasTimestamp() => $_has(6);
  @$pb.TagNumber(7)
  void clearTimestamp() => $_clearField(7);
  @$pb.TagNumber(7)
  $0.Timestamp ensureTimestamp() => $_ensure(6);
}

/// PromotionMessageResponse acknowledges a PromotionMessageRequest.
class PromotionMessageResponse extends $pb.GeneratedMessage {
  factory PromotionMessageResponse({
    ResponseStatus? status,
    $0.Timestamp? timestamp,
  }) {
    final result = create();
    if (status != null) result.status = status;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  PromotionMessageResponse._();

  factory PromotionMessageResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PromotionMessageResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PromotionMessageResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v1'),
      createEmptyInstance: create)
    ..aE<ResponseStatus>(1, _omitFieldNames ? '' : 'status',
        enumValues: ResponseStatus.values)
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PromotionMessageResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PromotionMessageResponse copyWith(
          void Function(PromotionMessageResponse) updates) =>
      super.copyWith((message) => updates(message as PromotionMessageResponse))
          as PromotionMessageResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PromotionMessageResponse create() => PromotionMessageResponse._();
  @$core.override
  PromotionMessageResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PromotionMessageResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PromotionMessageResponse>(create);
  static PromotionMessageResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ResponseStatus get status => $_getN(0);
  @$pb.TagNumber(1)
  set status(ResponseStatus value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Timestamp get timestamp => $_getN(1);
  @$pb.TagNumber(2)
  set timestamp($0.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestamp() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Timestamp ensureTimestamp() => $_ensure(1);
}

/// Product represents a single catalog item with pricing and quantity metadata.
class Product extends $pb.GeneratedMessage {
  factory Product({
    $core.String? sku,
    $core.String? name,
    $core.double? price,
    $core.Iterable<$core.String>? imagesUrl,
    $core.double? salePrice,
    $core.double? subunits,
    $core.double? unitStep,
    $core.String? unitName,
    $core.String? subunitName,
    $core.double? subunitStep,
    $core.double? unitsAdded,
    $core.double? subunitsAdded,
  }) {
    final result = create();
    if (sku != null) result.sku = sku;
    if (name != null) result.name = name;
    if (price != null) result.price = price;
    if (imagesUrl != null) result.imagesUrl.addAll(imagesUrl);
    if (salePrice != null) result.salePrice = salePrice;
    if (subunits != null) result.subunits = subunits;
    if (unitStep != null) result.unitStep = unitStep;
    if (unitName != null) result.unitName = unitName;
    if (subunitName != null) result.subunitName = subunitName;
    if (subunitStep != null) result.subunitStep = subunitStep;
    if (unitsAdded != null) result.unitsAdded = unitsAdded;
    if (subunitsAdded != null) result.subunitsAdded = subunitsAdded;
    return result;
  }

  Product._();

  factory Product.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Product.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Product',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sku')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aD(3, _omitFieldNames ? '' : 'price')
    ..pPS(4, _omitFieldNames ? '' : 'imagesUrl')
    ..aD(5, _omitFieldNames ? '' : 'salePrice')
    ..aD(6, _omitFieldNames ? '' : 'subunits')
    ..aD(7, _omitFieldNames ? '' : 'unitStep')
    ..aOS(8, _omitFieldNames ? '' : 'unitName')
    ..aOS(9, _omitFieldNames ? '' : 'subunitName')
    ..aD(10, _omitFieldNames ? '' : 'subunitStep')
    ..aD(11, _omitFieldNames ? '' : 'unitsAdded')
    ..aD(12, _omitFieldNames ? '' : 'subunitsAdded')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Product clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Product copyWith(void Function(Product) updates) =>
      super.copyWith((message) => updates(message as Product)) as Product;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Product create() => Product._();
  @$core.override
  Product createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Product getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Product>(create);
  static Product? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sku => $_getSZ(0);
  @$pb.TagNumber(1)
  set sku($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSku() => $_has(0);
  @$pb.TagNumber(1)
  void clearSku() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get price => $_getN(2);
  @$pb.TagNumber(3)
  set price($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPrice() => $_has(2);
  @$pb.TagNumber(3)
  void clearPrice() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<$core.String> get imagesUrl => $_getList(3);

  /// When set, sale_price takes precedence over price.
  @$pb.TagNumber(5)
  $core.double get salePrice => $_getN(4);
  @$pb.TagNumber(5)
  set salePrice($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSalePrice() => $_has(4);
  @$pb.TagNumber(5)
  void clearSalePrice() => $_clearField(5);

  /// Units per package (e.g. items inside a box). Used to compute quantity steps.
  @$pb.TagNumber(6)
  $core.double get subunits => $_getN(5);
  @$pb.TagNumber(6)
  set subunits($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSubunits() => $_has(5);
  @$pb.TagNumber(6)
  void clearSubunits() => $_clearField(6);

  /// Increment step when adjusting primary units.
  @$pb.TagNumber(7)
  $core.double get unitStep => $_getN(6);
  @$pb.TagNumber(7)
  set unitStep($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasUnitStep() => $_has(6);
  @$pb.TagNumber(7)
  void clearUnitStep() => $_clearField(7);

  /// ICU message-format string for the unit name, supports plurals via {amount}.
  /// e.g. "{amount, plural, one {box} other {boxes}}"
  @$pb.TagNumber(8)
  $core.String get unitName => $_getSZ(7);
  @$pb.TagNumber(8)
  set unitName($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasUnitName() => $_has(7);
  @$pb.TagNumber(8)
  void clearUnitName() => $_clearField(8);

  /// ICU message-format string for the subunit name, supports plurals via {amount}.
  @$pb.TagNumber(9)
  $core.String get subunitName => $_getSZ(8);
  @$pb.TagNumber(9)
  set subunitName($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasSubunitName() => $_has(8);
  @$pb.TagNumber(9)
  void clearSubunitName() => $_clearField(9);

  /// Increment step when adjusting subunits.
  @$pb.TagNumber(10)
  $core.double get subunitStep => $_getN(9);
  @$pb.TagNumber(10)
  set subunitStep($core.double value) => $_setDouble(9, value);
  @$pb.TagNumber(10)
  $core.bool hasSubunitStep() => $_has(9);
  @$pb.TagNumber(10)
  void clearSubunitStep() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.double get unitsAdded => $_getN(10);
  @$pb.TagNumber(11)
  set unitsAdded($core.double value) => $_setDouble(10, value);
  @$pb.TagNumber(11)
  $core.bool hasUnitsAdded() => $_has(10);
  @$pb.TagNumber(11)
  void clearUnitsAdded() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.double get subunitsAdded => $_getN(11);
  @$pb.TagNumber(12)
  set subunitsAdded($core.double value) => $_setDouble(11, value);
  @$pb.TagNumber(12)
  $core.bool hasSubunitsAdded() => $_has(11);
  @$pb.TagNumber(12)
  void clearSubunitsAdded() => $_clearField(12);
}

/// ProductMessageRequest delivers a list of products rendered as a vertical list or horizontal carousel.
class ProductMessageRequest extends $pb.GeneratedMessage {
  factory ProductMessageRequest({
    $core.Iterable<Product>? products,
    ProductMessageRequest_Orientation? orientation,
    $0.Timestamp? timestamp,
  }) {
    final result = create();
    if (products != null) result.products.addAll(products);
    if (orientation != null) result.orientation = orientation;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  ProductMessageRequest._();

  factory ProductMessageRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ProductMessageRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProductMessageRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v1'),
      createEmptyInstance: create)
    ..pPM<Product>(1, _omitFieldNames ? '' : 'products',
        subBuilder: Product.create)
    ..aE<ProductMessageRequest_Orientation>(
        2, _omitFieldNames ? '' : 'orientation',
        enumValues: ProductMessageRequest_Orientation.values)
    ..aOM<$0.Timestamp>(3, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProductMessageRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProductMessageRequest copyWith(
          void Function(ProductMessageRequest) updates) =>
      super.copyWith((message) => updates(message as ProductMessageRequest))
          as ProductMessageRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ProductMessageRequest create() => ProductMessageRequest._();
  @$core.override
  ProductMessageRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ProductMessageRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ProductMessageRequest>(create);
  static ProductMessageRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Product> get products => $_getList(0);

  @$pb.TagNumber(2)
  ProductMessageRequest_Orientation get orientation => $_getN(1);
  @$pb.TagNumber(2)
  set orientation(ProductMessageRequest_Orientation value) =>
      $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasOrientation() => $_has(1);
  @$pb.TagNumber(2)
  void clearOrientation() => $_clearField(2);

  @$pb.TagNumber(3)
  $0.Timestamp get timestamp => $_getN(2);
  @$pb.TagNumber(3)
  set timestamp($0.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasTimestamp() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimestamp() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.Timestamp ensureTimestamp() => $_ensure(2);
}

/// ProductMessageResponse acknowledges a ProductMessageRequest.
class ProductMessageResponse extends $pb.GeneratedMessage {
  factory ProductMessageResponse({
    ResponseStatus? status,
    $0.Timestamp? timestamp,
  }) {
    final result = create();
    if (status != null) result.status = status;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  ProductMessageResponse._();

  factory ProductMessageResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ProductMessageResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProductMessageResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v1'),
      createEmptyInstance: create)
    ..aE<ResponseStatus>(1, _omitFieldNames ? '' : 'status',
        enumValues: ResponseStatus.values)
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProductMessageResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProductMessageResponse copyWith(
          void Function(ProductMessageResponse) updates) =>
      super.copyWith((message) => updates(message as ProductMessageResponse))
          as ProductMessageResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ProductMessageResponse create() => ProductMessageResponse._();
  @$core.override
  ProductMessageResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ProductMessageResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ProductMessageResponse>(create);
  static ProductMessageResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ResponseStatus get status => $_getN(0);
  @$pb.TagNumber(1)
  set status(ResponseStatus value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Timestamp get timestamp => $_getN(1);
  @$pb.TagNumber(2)
  set timestamp($0.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestamp() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Timestamp ensureTimestamp() => $_ensure(1);
}

/// ChatStatusRequest pushes a custom status string to display in the chat UI.
class ChatStatusRequest extends $pb.GeneratedMessage {
  factory ChatStatusRequest({
    $core.String? status,
    $0.Timestamp? timestamp,
  }) {
    final result = create();
    if (status != null) result.status = status;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  ChatStatusRequest._();

  factory ChatStatusRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ChatStatusRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChatStatusRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'status')
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatStatusRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatStatusRequest copyWith(void Function(ChatStatusRequest) updates) =>
      super.copyWith((message) => updates(message as ChatStatusRequest))
          as ChatStatusRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChatStatusRequest create() => ChatStatusRequest._();
  @$core.override
  ChatStatusRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ChatStatusRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChatStatusRequest>(create);
  static ChatStatusRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get status => $_getSZ(0);
  @$pb.TagNumber(1)
  set status($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Timestamp get timestamp => $_getN(1);
  @$pb.TagNumber(2)
  set timestamp($0.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestamp() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Timestamp ensureTimestamp() => $_ensure(1);
}

/// ChatStatusResponse acknowledges a ChatStatusRequest.
class ChatStatusResponse extends $pb.GeneratedMessage {
  factory ChatStatusResponse({
    ResponseStatus? status,
    $0.Timestamp? timestamp,
  }) {
    final result = create();
    if (status != null) result.status = status;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  ChatStatusResponse._();

  factory ChatStatusResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ChatStatusResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChatStatusResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v1'),
      createEmptyInstance: create)
    ..aE<ResponseStatus>(1, _omitFieldNames ? '' : 'status',
        enumValues: ResponseStatus.values)
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatStatusResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatStatusResponse copyWith(void Function(ChatStatusResponse) updates) =>
      super.copyWith((message) => updates(message as ChatStatusResponse))
          as ChatStatusResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChatStatusResponse create() => ChatStatusResponse._();
  @$core.override
  ChatStatusResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ChatStatusResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChatStatusResponse>(create);
  static ChatStatusResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ResponseStatus get status => $_getN(0);
  @$pb.TagNumber(1)
  set status(ResponseStatus value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Timestamp get timestamp => $_getN(1);
  @$pb.TagNumber(2)
  set timestamp($0.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestamp() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Timestamp ensureTimestamp() => $_ensure(1);
}

/// CustomActionRequest triggers a client-side action identified by action_id.
class CustomActionRequest extends $pb.GeneratedMessage {
  factory CustomActionRequest({
    $core.String? actionId,
    $core.String? payload,
    $0.Timestamp? timestamp,
  }) {
    final result = create();
    if (actionId != null) result.actionId = actionId;
    if (payload != null) result.payload = payload;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  CustomActionRequest._();

  factory CustomActionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CustomActionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CustomActionRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'actionId')
    ..aOS(2, _omitFieldNames ? '' : 'payload')
    ..aOM<$0.Timestamp>(3, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CustomActionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CustomActionRequest copyWith(void Function(CustomActionRequest) updates) =>
      super.copyWith((message) => updates(message as CustomActionRequest))
          as CustomActionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CustomActionRequest create() => CustomActionRequest._();
  @$core.override
  CustomActionRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CustomActionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CustomActionRequest>(create);
  static CustomActionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get actionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set actionId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasActionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearActionId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get payload => $_getSZ(1);
  @$pb.TagNumber(2)
  set payload($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPayload() => $_has(1);
  @$pb.TagNumber(2)
  void clearPayload() => $_clearField(2);

  @$pb.TagNumber(3)
  $0.Timestamp get timestamp => $_getN(2);
  @$pb.TagNumber(3)
  set timestamp($0.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasTimestamp() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimestamp() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.Timestamp ensureTimestamp() => $_ensure(2);
}

/// CustomActionResponse returns the result of a CustomActionRequest.
class CustomActionResponse extends $pb.GeneratedMessage {
  factory CustomActionResponse({
    ResponseStatus? status,
    $core.String? payload,
    $0.Timestamp? timestamp,
  }) {
    final result = create();
    if (status != null) result.status = status;
    if (payload != null) result.payload = payload;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  CustomActionResponse._();

  factory CustomActionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CustomActionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CustomActionResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v1'),
      createEmptyInstance: create)
    ..aE<ResponseStatus>(1, _omitFieldNames ? '' : 'status',
        enumValues: ResponseStatus.values)
    ..aOS(2, _omitFieldNames ? '' : 'payload')
    ..aOM<$0.Timestamp>(3, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CustomActionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CustomActionResponse copyWith(void Function(CustomActionResponse) updates) =>
      super.copyWith((message) => updates(message as CustomActionResponse))
          as CustomActionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CustomActionResponse create() => CustomActionResponse._();
  @$core.override
  CustomActionResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CustomActionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CustomActionResponse>(create);
  static CustomActionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ResponseStatus get status => $_getN(0);
  @$pb.TagNumber(1)
  set status(ResponseStatus value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get payload => $_getSZ(1);
  @$pb.TagNumber(2)
  set payload($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPayload() => $_has(1);
  @$pb.TagNumber(2)
  void clearPayload() => $_clearField(2);

  @$pb.TagNumber(3)
  $0.Timestamp get timestamp => $_getN(2);
  @$pb.TagNumber(3)
  set timestamp($0.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasTimestamp() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimestamp() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.Timestamp ensureTimestamp() => $_ensure(2);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
