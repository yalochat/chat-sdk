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

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart'
    as $0;

import 'sdk_message.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'sdk_message.pbenum.dart';

enum SdkMessage_Payload {
  textMessageRequest,
  textMessageResponse,
  voiceNoteMessageRequest,
  voiceNoteMessageResponse,
  imageMessageRequest,
  imageMessageResponse,
  messageReceiptRequest,
  messageReceiptResponse,
  attachmentMessageRequest,
  attachmentMessageResponse,
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
  videoMessageRequest,
  videoMessageResponse,
  buttonsMessageRequest,
  buttonsMessageResponse,
  ctaMessageRequest,
  ctaMessageResponse,
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
    VoiceNoteMessageRequest? voiceNoteMessageRequest,
    VoiceNoteMessageResponse? voiceNoteMessageResponse,
    ImageMessageRequest? imageMessageRequest,
    ImageMessageResponse? imageMessageResponse,
    MessageReceiptRequest? messageReceiptRequest,
    MessageReceiptResponse? messageReceiptResponse,
    AttachmentMessageRequest? attachmentMessageRequest,
    AttachmentMessageResponse? attachmentMessageResponse,
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
    VideoMessageRequest? videoMessageRequest,
    VideoMessageResponse? videoMessageResponse,
    ButtonsMessageRequest? buttonsMessageRequest,
    ButtonsMessageResponse? buttonsMessageResponse,
    CTAMessageRequest? ctaMessageRequest,
    CTAMessageResponse? ctaMessageResponse,
  }) {
    final result = create();
    if (correlationId != null) result.correlationId = correlationId;
    if (timestamp != null) result.timestamp = timestamp;
    if (textMessageRequest != null)
      result.textMessageRequest = textMessageRequest;
    if (textMessageResponse != null)
      result.textMessageResponse = textMessageResponse;
    if (voiceNoteMessageRequest != null)
      result.voiceNoteMessageRequest = voiceNoteMessageRequest;
    if (voiceNoteMessageResponse != null)
      result.voiceNoteMessageResponse = voiceNoteMessageResponse;
    if (imageMessageRequest != null)
      result.imageMessageRequest = imageMessageRequest;
    if (imageMessageResponse != null)
      result.imageMessageResponse = imageMessageResponse;
    if (messageReceiptRequest != null)
      result.messageReceiptRequest = messageReceiptRequest;
    if (messageReceiptResponse != null)
      result.messageReceiptResponse = messageReceiptResponse;
    if (attachmentMessageRequest != null)
      result.attachmentMessageRequest = attachmentMessageRequest;
    if (attachmentMessageResponse != null)
      result.attachmentMessageResponse = attachmentMessageResponse;
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
    if (videoMessageRequest != null)
      result.videoMessageRequest = videoMessageRequest;
    if (videoMessageResponse != null)
      result.videoMessageResponse = videoMessageResponse;
    if (buttonsMessageRequest != null)
      result.buttonsMessageRequest = buttonsMessageRequest;
    if (buttonsMessageResponse != null)
      result.buttonsMessageResponse = buttonsMessageResponse;
    if (ctaMessageRequest != null) result.ctaMessageRequest = ctaMessageRequest;
    if (ctaMessageResponse != null)
      result.ctaMessageResponse = ctaMessageResponse;
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
    12: SdkMessage_Payload.voiceNoteMessageRequest,
    13: SdkMessage_Payload.voiceNoteMessageResponse,
    14: SdkMessage_Payload.imageMessageRequest,
    15: SdkMessage_Payload.imageMessageResponse,
    16: SdkMessage_Payload.messageReceiptRequest,
    17: SdkMessage_Payload.messageReceiptResponse,
    18: SdkMessage_Payload.attachmentMessageRequest,
    19: SdkMessage_Payload.attachmentMessageResponse,
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
    38: SdkMessage_Payload.videoMessageRequest,
    39: SdkMessage_Payload.videoMessageResponse,
    40: SdkMessage_Payload.buttonsMessageRequest,
    41: SdkMessage_Payload.buttonsMessageResponse,
    42: SdkMessage_Payload.ctaMessageRequest,
    43: SdkMessage_Payload.ctaMessageResponse,
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
      18,
      19,
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
      37,
      38,
      39,
      40,
      41,
      42,
      43
    ])
    ..aOS(1, _omitFieldNames ? '' : 'correlationId')
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..aOM<TextMessageRequest>(10, _omitFieldNames ? '' : 'textMessageRequest',
        subBuilder: TextMessageRequest.create)
    ..aOM<TextMessageResponse>(11, _omitFieldNames ? '' : 'textMessageResponse',
        subBuilder: TextMessageResponse.create)
    ..aOM<VoiceNoteMessageRequest>(
        12, _omitFieldNames ? '' : 'voiceNoteMessageRequest',
        subBuilder: VoiceNoteMessageRequest.create)
    ..aOM<VoiceNoteMessageResponse>(
        13, _omitFieldNames ? '' : 'voiceNoteMessageResponse',
        subBuilder: VoiceNoteMessageResponse.create)
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
    ..aOM<AttachmentMessageRequest>(
        18, _omitFieldNames ? '' : 'attachmentMessageRequest',
        subBuilder: AttachmentMessageRequest.create)
    ..aOM<AttachmentMessageResponse>(
        19, _omitFieldNames ? '' : 'attachmentMessageResponse',
        subBuilder: AttachmentMessageResponse.create)
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
    ..aOM<VideoMessageRequest>(38, _omitFieldNames ? '' : 'videoMessageRequest',
        subBuilder: VideoMessageRequest.create)
    ..aOM<VideoMessageResponse>(
        39, _omitFieldNames ? '' : 'videoMessageResponse',
        subBuilder: VideoMessageResponse.create)
    ..aOM<ButtonsMessageRequest>(
        40, _omitFieldNames ? '' : 'buttonsMessageRequest',
        subBuilder: ButtonsMessageRequest.create)
    ..aOM<ButtonsMessageResponse>(
        41, _omitFieldNames ? '' : 'buttonsMessageResponse',
        subBuilder: ButtonsMessageResponse.create)
    ..aOM<CTAMessageRequest>(42, _omitFieldNames ? '' : 'ctaMessageRequest',
        subBuilder: CTAMessageRequest.create)
    ..aOM<CTAMessageResponse>(43, _omitFieldNames ? '' : 'ctaMessageResponse',
        subBuilder: CTAMessageResponse.create)
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
  @$pb.TagNumber(18)
  @$pb.TagNumber(19)
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
  @$pb.TagNumber(38)
  @$pb.TagNumber(39)
  @$pb.TagNumber(40)
  @$pb.TagNumber(41)
  @$pb.TagNumber(42)
  @$pb.TagNumber(43)
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
  @$pb.TagNumber(18)
  @$pb.TagNumber(19)
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
  @$pb.TagNumber(38)
  @$pb.TagNumber(39)
  @$pb.TagNumber(40)
  @$pb.TagNumber(41)
  @$pb.TagNumber(42)
  @$pb.TagNumber(43)
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
  VoiceNoteMessageRequest get voiceNoteMessageRequest => $_getN(4);
  @$pb.TagNumber(12)
  set voiceNoteMessageRequest(VoiceNoteMessageRequest value) =>
      $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasVoiceNoteMessageRequest() => $_has(4);
  @$pb.TagNumber(12)
  void clearVoiceNoteMessageRequest() => $_clearField(12);
  @$pb.TagNumber(12)
  VoiceNoteMessageRequest ensureVoiceNoteMessageRequest() => $_ensure(4);

  @$pb.TagNumber(13)
  VoiceNoteMessageResponse get voiceNoteMessageResponse => $_getN(5);
  @$pb.TagNumber(13)
  set voiceNoteMessageResponse(VoiceNoteMessageResponse value) =>
      $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasVoiceNoteMessageResponse() => $_has(5);
  @$pb.TagNumber(13)
  void clearVoiceNoteMessageResponse() => $_clearField(13);
  @$pb.TagNumber(13)
  VoiceNoteMessageResponse ensureVoiceNoteMessageResponse() => $_ensure(5);

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

  @$pb.TagNumber(18)
  AttachmentMessageRequest get attachmentMessageRequest => $_getN(10);
  @$pb.TagNumber(18)
  set attachmentMessageRequest(AttachmentMessageRequest value) =>
      $_setField(18, value);
  @$pb.TagNumber(18)
  $core.bool hasAttachmentMessageRequest() => $_has(10);
  @$pb.TagNumber(18)
  void clearAttachmentMessageRequest() => $_clearField(18);
  @$pb.TagNumber(18)
  AttachmentMessageRequest ensureAttachmentMessageRequest() => $_ensure(10);

  @$pb.TagNumber(19)
  AttachmentMessageResponse get attachmentMessageResponse => $_getN(11);
  @$pb.TagNumber(19)
  set attachmentMessageResponse(AttachmentMessageResponse value) =>
      $_setField(19, value);
  @$pb.TagNumber(19)
  $core.bool hasAttachmentMessageResponse() => $_has(11);
  @$pb.TagNumber(19)
  void clearAttachmentMessageResponse() => $_clearField(19);
  @$pb.TagNumber(19)
  AttachmentMessageResponse ensureAttachmentMessageResponse() => $_ensure(11);

  /// Client → channel
  @$pb.TagNumber(20)
  AddToCartRequest get addToCartRequest => $_getN(12);
  @$pb.TagNumber(20)
  set addToCartRequest(AddToCartRequest value) => $_setField(20, value);
  @$pb.TagNumber(20)
  $core.bool hasAddToCartRequest() => $_has(12);
  @$pb.TagNumber(20)
  void clearAddToCartRequest() => $_clearField(20);
  @$pb.TagNumber(20)
  AddToCartRequest ensureAddToCartRequest() => $_ensure(12);

  @$pb.TagNumber(21)
  AddToCartResponse get addToCartResponse => $_getN(13);
  @$pb.TagNumber(21)
  set addToCartResponse(AddToCartResponse value) => $_setField(21, value);
  @$pb.TagNumber(21)
  $core.bool hasAddToCartResponse() => $_has(13);
  @$pb.TagNumber(21)
  void clearAddToCartResponse() => $_clearField(21);
  @$pb.TagNumber(21)
  AddToCartResponse ensureAddToCartResponse() => $_ensure(13);

  @$pb.TagNumber(22)
  RemoveFromCartRequest get removeFromCartRequest => $_getN(14);
  @$pb.TagNumber(22)
  set removeFromCartRequest(RemoveFromCartRequest value) =>
      $_setField(22, value);
  @$pb.TagNumber(22)
  $core.bool hasRemoveFromCartRequest() => $_has(14);
  @$pb.TagNumber(22)
  void clearRemoveFromCartRequest() => $_clearField(22);
  @$pb.TagNumber(22)
  RemoveFromCartRequest ensureRemoveFromCartRequest() => $_ensure(14);

  @$pb.TagNumber(23)
  RemoveFromCartResponse get removeFromCartResponse => $_getN(15);
  @$pb.TagNumber(23)
  set removeFromCartResponse(RemoveFromCartResponse value) =>
      $_setField(23, value);
  @$pb.TagNumber(23)
  $core.bool hasRemoveFromCartResponse() => $_has(15);
  @$pb.TagNumber(23)
  void clearRemoveFromCartResponse() => $_clearField(23);
  @$pb.TagNumber(23)
  RemoveFromCartResponse ensureRemoveFromCartResponse() => $_ensure(15);

  @$pb.TagNumber(24)
  ClearCartRequest get clearCartRequest => $_getN(16);
  @$pb.TagNumber(24)
  set clearCartRequest(ClearCartRequest value) => $_setField(24, value);
  @$pb.TagNumber(24)
  $core.bool hasClearCartRequest() => $_has(16);
  @$pb.TagNumber(24)
  void clearClearCartRequest() => $_clearField(24);
  @$pb.TagNumber(24)
  ClearCartRequest ensureClearCartRequest() => $_ensure(16);

  @$pb.TagNumber(25)
  ClearCartResponse get clearCartResponse => $_getN(17);
  @$pb.TagNumber(25)
  set clearCartResponse(ClearCartResponse value) => $_setField(25, value);
  @$pb.TagNumber(25)
  $core.bool hasClearCartResponse() => $_has(17);
  @$pb.TagNumber(25)
  void clearClearCartResponse() => $_clearField(25);
  @$pb.TagNumber(25)
  ClearCartResponse ensureClearCartResponse() => $_ensure(17);

  @$pb.TagNumber(26)
  GuidanceCardRequest get guidanceCardRequest => $_getN(18);
  @$pb.TagNumber(26)
  set guidanceCardRequest(GuidanceCardRequest value) => $_setField(26, value);
  @$pb.TagNumber(26)
  $core.bool hasGuidanceCardRequest() => $_has(18);
  @$pb.TagNumber(26)
  void clearGuidanceCardRequest() => $_clearField(26);
  @$pb.TagNumber(26)
  GuidanceCardRequest ensureGuidanceCardRequest() => $_ensure(18);

  @$pb.TagNumber(27)
  GuidanceCardResponse get guidanceCardResponse => $_getN(19);
  @$pb.TagNumber(27)
  set guidanceCardResponse(GuidanceCardResponse value) => $_setField(27, value);
  @$pb.TagNumber(27)
  $core.bool hasGuidanceCardResponse() => $_has(19);
  @$pb.TagNumber(27)
  void clearGuidanceCardResponse() => $_clearField(27);
  @$pb.TagNumber(27)
  GuidanceCardResponse ensureGuidanceCardResponse() => $_ensure(19);

  @$pb.TagNumber(28)
  AddPromotionRequest get addPromotionRequest => $_getN(20);
  @$pb.TagNumber(28)
  set addPromotionRequest(AddPromotionRequest value) => $_setField(28, value);
  @$pb.TagNumber(28)
  $core.bool hasAddPromotionRequest() => $_has(20);
  @$pb.TagNumber(28)
  void clearAddPromotionRequest() => $_clearField(28);
  @$pb.TagNumber(28)
  AddPromotionRequest ensureAddPromotionRequest() => $_ensure(20);

  @$pb.TagNumber(29)
  AddPromotionResponse get addPromotionResponse => $_getN(21);
  @$pb.TagNumber(29)
  set addPromotionResponse(AddPromotionResponse value) => $_setField(29, value);
  @$pb.TagNumber(29)
  $core.bool hasAddPromotionResponse() => $_has(21);
  @$pb.TagNumber(29)
  void clearAddPromotionResponse() => $_clearField(29);
  @$pb.TagNumber(29)
  AddPromotionResponse ensureAddPromotionResponse() => $_ensure(21);

  /// Channel → client
  @$pb.TagNumber(30)
  PromotionMessageRequest get promotionMessageRequest => $_getN(22);
  @$pb.TagNumber(30)
  set promotionMessageRequest(PromotionMessageRequest value) =>
      $_setField(30, value);
  @$pb.TagNumber(30)
  $core.bool hasPromotionMessageRequest() => $_has(22);
  @$pb.TagNumber(30)
  void clearPromotionMessageRequest() => $_clearField(30);
  @$pb.TagNumber(30)
  PromotionMessageRequest ensurePromotionMessageRequest() => $_ensure(22);

  @$pb.TagNumber(31)
  PromotionMessageResponse get promotionMessageResponse => $_getN(23);
  @$pb.TagNumber(31)
  set promotionMessageResponse(PromotionMessageResponse value) =>
      $_setField(31, value);
  @$pb.TagNumber(31)
  $core.bool hasPromotionMessageResponse() => $_has(23);
  @$pb.TagNumber(31)
  void clearPromotionMessageResponse() => $_clearField(31);
  @$pb.TagNumber(31)
  PromotionMessageResponse ensurePromotionMessageResponse() => $_ensure(23);

  @$pb.TagNumber(32)
  ProductMessageRequest get productMessageRequest => $_getN(24);
  @$pb.TagNumber(32)
  set productMessageRequest(ProductMessageRequest value) =>
      $_setField(32, value);
  @$pb.TagNumber(32)
  $core.bool hasProductMessageRequest() => $_has(24);
  @$pb.TagNumber(32)
  void clearProductMessageRequest() => $_clearField(32);
  @$pb.TagNumber(32)
  ProductMessageRequest ensureProductMessageRequest() => $_ensure(24);

  @$pb.TagNumber(33)
  ProductMessageResponse get productMessageResponse => $_getN(25);
  @$pb.TagNumber(33)
  set productMessageResponse(ProductMessageResponse value) =>
      $_setField(33, value);
  @$pb.TagNumber(33)
  $core.bool hasProductMessageResponse() => $_has(25);
  @$pb.TagNumber(33)
  void clearProductMessageResponse() => $_clearField(33);
  @$pb.TagNumber(33)
  ProductMessageResponse ensureProductMessageResponse() => $_ensure(25);

  @$pb.TagNumber(34)
  ChatStatusRequest get chatStatusRequest => $_getN(26);
  @$pb.TagNumber(34)
  set chatStatusRequest(ChatStatusRequest value) => $_setField(34, value);
  @$pb.TagNumber(34)
  $core.bool hasChatStatusRequest() => $_has(26);
  @$pb.TagNumber(34)
  void clearChatStatusRequest() => $_clearField(34);
  @$pb.TagNumber(34)
  ChatStatusRequest ensureChatStatusRequest() => $_ensure(26);

  @$pb.TagNumber(35)
  ChatStatusResponse get chatStatusResponse => $_getN(27);
  @$pb.TagNumber(35)
  set chatStatusResponse(ChatStatusResponse value) => $_setField(35, value);
  @$pb.TagNumber(35)
  $core.bool hasChatStatusResponse() => $_has(27);
  @$pb.TagNumber(35)
  void clearChatStatusResponse() => $_clearField(35);
  @$pb.TagNumber(35)
  ChatStatusResponse ensureChatStatusResponse() => $_ensure(27);

  @$pb.TagNumber(36)
  CustomActionRequest get customActionRequest => $_getN(28);
  @$pb.TagNumber(36)
  set customActionRequest(CustomActionRequest value) => $_setField(36, value);
  @$pb.TagNumber(36)
  $core.bool hasCustomActionRequest() => $_has(28);
  @$pb.TagNumber(36)
  void clearCustomActionRequest() => $_clearField(36);
  @$pb.TagNumber(36)
  CustomActionRequest ensureCustomActionRequest() => $_ensure(28);

  @$pb.TagNumber(37)
  CustomActionResponse get customActionResponse => $_getN(29);
  @$pb.TagNumber(37)
  set customActionResponse(CustomActionResponse value) => $_setField(37, value);
  @$pb.TagNumber(37)
  $core.bool hasCustomActionResponse() => $_has(29);
  @$pb.TagNumber(37)
  void clearCustomActionResponse() => $_clearField(37);
  @$pb.TagNumber(37)
  CustomActionResponse ensureCustomActionResponse() => $_ensure(29);

  @$pb.TagNumber(38)
  VideoMessageRequest get videoMessageRequest => $_getN(30);
  @$pb.TagNumber(38)
  set videoMessageRequest(VideoMessageRequest value) => $_setField(38, value);
  @$pb.TagNumber(38)
  $core.bool hasVideoMessageRequest() => $_has(30);
  @$pb.TagNumber(38)
  void clearVideoMessageRequest() => $_clearField(38);
  @$pb.TagNumber(38)
  VideoMessageRequest ensureVideoMessageRequest() => $_ensure(30);

  @$pb.TagNumber(39)
  VideoMessageResponse get videoMessageResponse => $_getN(31);
  @$pb.TagNumber(39)
  set videoMessageResponse(VideoMessageResponse value) => $_setField(39, value);
  @$pb.TagNumber(39)
  $core.bool hasVideoMessageResponse() => $_has(31);
  @$pb.TagNumber(39)
  void clearVideoMessageResponse() => $_clearField(39);
  @$pb.TagNumber(39)
  VideoMessageResponse ensureVideoMessageResponse() => $_ensure(31);

  /// Channel → client
  @$pb.TagNumber(40)
  ButtonsMessageRequest get buttonsMessageRequest => $_getN(32);
  @$pb.TagNumber(40)
  set buttonsMessageRequest(ButtonsMessageRequest value) =>
      $_setField(40, value);
  @$pb.TagNumber(40)
  $core.bool hasButtonsMessageRequest() => $_has(32);
  @$pb.TagNumber(40)
  void clearButtonsMessageRequest() => $_clearField(40);
  @$pb.TagNumber(40)
  ButtonsMessageRequest ensureButtonsMessageRequest() => $_ensure(32);

  @$pb.TagNumber(41)
  ButtonsMessageResponse get buttonsMessageResponse => $_getN(33);
  @$pb.TagNumber(41)
  set buttonsMessageResponse(ButtonsMessageResponse value) =>
      $_setField(41, value);
  @$pb.TagNumber(41)
  $core.bool hasButtonsMessageResponse() => $_has(33);
  @$pb.TagNumber(41)
  void clearButtonsMessageResponse() => $_clearField(41);
  @$pb.TagNumber(41)
  ButtonsMessageResponse ensureButtonsMessageResponse() => $_ensure(33);

  @$pb.TagNumber(42)
  CTAMessageRequest get ctaMessageRequest => $_getN(34);
  @$pb.TagNumber(42)
  set ctaMessageRequest(CTAMessageRequest value) => $_setField(42, value);
  @$pb.TagNumber(42)
  $core.bool hasCtaMessageRequest() => $_has(34);
  @$pb.TagNumber(42)
  void clearCtaMessageRequest() => $_clearField(42);
  @$pb.TagNumber(42)
  CTAMessageRequest ensureCtaMessageRequest() => $_ensure(34);

  @$pb.TagNumber(43)
  CTAMessageResponse get ctaMessageResponse => $_getN(35);
  @$pb.TagNumber(43)
  set ctaMessageResponse(CTAMessageResponse value) => $_setField(43, value);
  @$pb.TagNumber(43)
  $core.bool hasCtaMessageResponse() => $_has(35);
  @$pb.TagNumber(43)
  void clearCtaMessageResponse() => $_clearField(43);
  @$pb.TagNumber(43)
  CTAMessageResponse ensureCtaMessageResponse() => $_ensure(35);
}

/// TextMessage holds the payload of a plain-text conversation turn.
class TextMessage extends $pb.GeneratedMessage {
  factory TextMessage({
    $0.Timestamp? timestamp,
    $core.String? text,
    MessageStatus? status,
    MessageRole? role,
  }) {
    final result = create();
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
    ..aOM<$0.Timestamp>(1, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..aOS(2, _omitFieldNames ? '' : 'text')
    ..aE<MessageStatus>(3, _omitFieldNames ? '' : 'status',
        enumValues: MessageStatus.values)
    ..aE<MessageRole>(4, _omitFieldNames ? '' : 'role',
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
  $0.Timestamp get timestamp => $_getN(0);
  @$pb.TagNumber(1)
  set timestamp($0.Timestamp value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTimestamp() => $_has(0);
  @$pb.TagNumber(1)
  void clearTimestamp() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Timestamp ensureTimestamp() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get text => $_getSZ(1);
  @$pb.TagNumber(2)
  set text($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasText() => $_has(1);
  @$pb.TagNumber(2)
  void clearText() => $_clearField(2);

  @$pb.TagNumber(3)
  MessageStatus get status => $_getN(2);
  @$pb.TagNumber(3)
  set status(MessageStatus value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearStatus() => $_clearField(3);

  @$pb.TagNumber(4)
  MessageRole get role => $_getN(3);
  @$pb.TagNumber(4)
  set role(MessageRole value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasRole() => $_has(3);
  @$pb.TagNumber(4)
  void clearRole() => $_clearField(4);
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
    $0.Timestamp? timestamp,
    $core.String? mediaUrl,
    $core.Iterable<$core.double>? amplitudesPreview,
    $core.double? duration,
    $core.String? mediaType,
    MessageStatus? status,
    MessageRole? role,
    $fixnum.Int64? byteCount,
    $core.String? fileName,
  }) {
    final result = create();
    if (timestamp != null) result.timestamp = timestamp;
    if (mediaUrl != null) result.mediaUrl = mediaUrl;
    if (amplitudesPreview != null)
      result.amplitudesPreview.addAll(amplitudesPreview);
    if (duration != null) result.duration = duration;
    if (mediaType != null) result.mediaType = mediaType;
    if (status != null) result.status = status;
    if (role != null) result.role = role;
    if (byteCount != null) result.byteCount = byteCount;
    if (fileName != null) result.fileName = fileName;
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
    ..aOM<$0.Timestamp>(1, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..aOS(2, _omitFieldNames ? '' : 'mediaUrl')
    ..p<$core.double>(
        3, _omitFieldNames ? '' : 'amplitudesPreview', $pb.PbFieldType.KF)
    ..aD(4, _omitFieldNames ? '' : 'duration')
    ..aOS(5, _omitFieldNames ? '' : 'mediaType')
    ..aE<MessageStatus>(6, _omitFieldNames ? '' : 'status',
        enumValues: MessageStatus.values)
    ..aE<MessageRole>(7, _omitFieldNames ? '' : 'role',
        enumValues: MessageRole.values)
    ..aInt64(8, _omitFieldNames ? '' : 'byteCount')
    ..aOS(9, _omitFieldNames ? '' : 'fileName')
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
  $0.Timestamp get timestamp => $_getN(0);
  @$pb.TagNumber(1)
  set timestamp($0.Timestamp value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTimestamp() => $_has(0);
  @$pb.TagNumber(1)
  void clearTimestamp() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Timestamp ensureTimestamp() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get mediaUrl => $_getSZ(1);
  @$pb.TagNumber(2)
  set mediaUrl($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMediaUrl() => $_has(1);
  @$pb.TagNumber(2)
  void clearMediaUrl() => $_clearField(2);

  /// Amplitude samples used to render the waveform preview in the UI.
  @$pb.TagNumber(3)
  $pb.PbList<$core.double> get amplitudesPreview => $_getList(2);

  @$pb.TagNumber(4)
  $core.double get duration => $_getN(3);
  @$pb.TagNumber(4)
  set duration($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDuration() => $_has(3);
  @$pb.TagNumber(4)
  void clearDuration() => $_clearField(4);

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

  @$pb.TagNumber(8)
  $fixnum.Int64 get byteCount => $_getI64(7);
  @$pb.TagNumber(8)
  set byteCount($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasByteCount() => $_has(7);
  @$pb.TagNumber(8)
  void clearByteCount() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get fileName => $_getSZ(8);
  @$pb.TagNumber(9)
  set fileName($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasFileName() => $_has(8);
  @$pb.TagNumber(9)
  void clearFileName() => $_clearField(9);
}

/// VoiceNoteMessageRequest is sent by either party to deliver a voice note.
class VoiceNoteMessageRequest extends $pb.GeneratedMessage {
  factory VoiceNoteMessageRequest({
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

  VoiceNoteMessageRequest._();

  factory VoiceNoteMessageRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory VoiceNoteMessageRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'VoiceNoteMessageRequest',
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
  VoiceNoteMessageRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VoiceNoteMessageRequest copyWith(
          void Function(VoiceNoteMessageRequest) updates) =>
      super.copyWith((message) => updates(message as VoiceNoteMessageRequest))
          as VoiceNoteMessageRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VoiceNoteMessageRequest create() => VoiceNoteMessageRequest._();
  @$core.override
  VoiceNoteMessageRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static VoiceNoteMessageRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<VoiceNoteMessageRequest>(create);
  static VoiceNoteMessageRequest? _defaultInstance;

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

/// VoiceNoteMessageResponse acknowledges a VoiceNoteMessageRequest and returns the assigned message id.
class VoiceNoteMessageResponse extends $pb.GeneratedMessage {
  factory VoiceNoteMessageResponse({
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

  VoiceNoteMessageResponse._();

  factory VoiceNoteMessageResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory VoiceNoteMessageResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'VoiceNoteMessageResponse',
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
  VoiceNoteMessageResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VoiceNoteMessageResponse copyWith(
          void Function(VoiceNoteMessageResponse) updates) =>
      super.copyWith((message) => updates(message as VoiceNoteMessageResponse))
          as VoiceNoteMessageResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VoiceNoteMessageResponse create() => VoiceNoteMessageResponse._();
  @$core.override
  VoiceNoteMessageResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static VoiceNoteMessageResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<VoiceNoteMessageResponse>(create);
  static VoiceNoteMessageResponse? _defaultInstance;

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
    $0.Timestamp? timestamp,
    $core.String? text,
    $core.String? mediaUrl,
    $core.String? mediaType,
    MessageStatus? status,
    MessageRole? role,
    $fixnum.Int64? byteCount,
    $core.String? fileName,
  }) {
    final result = create();
    if (timestamp != null) result.timestamp = timestamp;
    if (text != null) result.text = text;
    if (mediaUrl != null) result.mediaUrl = mediaUrl;
    if (mediaType != null) result.mediaType = mediaType;
    if (status != null) result.status = status;
    if (role != null) result.role = role;
    if (byteCount != null) result.byteCount = byteCount;
    if (fileName != null) result.fileName = fileName;
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
    ..aOM<$0.Timestamp>(1, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..aOS(2, _omitFieldNames ? '' : 'text')
    ..aOS(3, _omitFieldNames ? '' : 'mediaUrl')
    ..aOS(4, _omitFieldNames ? '' : 'mediaType')
    ..aE<MessageStatus>(5, _omitFieldNames ? '' : 'status',
        enumValues: MessageStatus.values)
    ..aE<MessageRole>(6, _omitFieldNames ? '' : 'role',
        enumValues: MessageRole.values)
    ..aInt64(7, _omitFieldNames ? '' : 'byteCount')
    ..aOS(8, _omitFieldNames ? '' : 'fileName')
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
  $0.Timestamp get timestamp => $_getN(0);
  @$pb.TagNumber(1)
  set timestamp($0.Timestamp value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTimestamp() => $_has(0);
  @$pb.TagNumber(1)
  void clearTimestamp() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Timestamp ensureTimestamp() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get text => $_getSZ(1);
  @$pb.TagNumber(2)
  set text($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasText() => $_has(1);
  @$pb.TagNumber(2)
  void clearText() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get mediaUrl => $_getSZ(2);
  @$pb.TagNumber(3)
  set mediaUrl($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMediaUrl() => $_has(2);
  @$pb.TagNumber(3)
  void clearMediaUrl() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get mediaType => $_getSZ(3);
  @$pb.TagNumber(4)
  set mediaType($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMediaType() => $_has(3);
  @$pb.TagNumber(4)
  void clearMediaType() => $_clearField(4);

  @$pb.TagNumber(5)
  MessageStatus get status => $_getN(4);
  @$pb.TagNumber(5)
  set status(MessageStatus value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearStatus() => $_clearField(5);

  @$pb.TagNumber(6)
  MessageRole get role => $_getN(5);
  @$pb.TagNumber(6)
  set role(MessageRole value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasRole() => $_has(5);
  @$pb.TagNumber(6)
  void clearRole() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get byteCount => $_getI64(6);
  @$pb.TagNumber(7)
  set byteCount($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasByteCount() => $_has(6);
  @$pb.TagNumber(7)
  void clearByteCount() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get fileName => $_getSZ(7);
  @$pb.TagNumber(8)
  set fileName($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasFileName() => $_has(7);
  @$pb.TagNumber(8)
  void clearFileName() => $_clearField(8);
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

/// AttachmentMessage holds the payload of a file attachment conversation turn.
class AttachmentMessage extends $pb.GeneratedMessage {
  factory AttachmentMessage({
    $0.Timestamp? timestamp,
    $core.String? text,
    $core.String? mediaUrl,
    $core.String? mediaType,
    MessageStatus? status,
    MessageRole? role,
    $fixnum.Int64? byteCount,
    $core.String? fileName,
  }) {
    final result = create();
    if (timestamp != null) result.timestamp = timestamp;
    if (text != null) result.text = text;
    if (mediaUrl != null) result.mediaUrl = mediaUrl;
    if (mediaType != null) result.mediaType = mediaType;
    if (status != null) result.status = status;
    if (role != null) result.role = role;
    if (byteCount != null) result.byteCount = byteCount;
    if (fileName != null) result.fileName = fileName;
    return result;
  }

  AttachmentMessage._();

  factory AttachmentMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AttachmentMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AttachmentMessage',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v1'),
      createEmptyInstance: create)
    ..aOM<$0.Timestamp>(1, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..aOS(2, _omitFieldNames ? '' : 'text')
    ..aOS(3, _omitFieldNames ? '' : 'mediaUrl')
    ..aOS(4, _omitFieldNames ? '' : 'mediaType')
    ..aE<MessageStatus>(5, _omitFieldNames ? '' : 'status',
        enumValues: MessageStatus.values)
    ..aE<MessageRole>(6, _omitFieldNames ? '' : 'role',
        enumValues: MessageRole.values)
    ..aInt64(7, _omitFieldNames ? '' : 'byteCount')
    ..aOS(8, _omitFieldNames ? '' : 'fileName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AttachmentMessage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AttachmentMessage copyWith(void Function(AttachmentMessage) updates) =>
      super.copyWith((message) => updates(message as AttachmentMessage))
          as AttachmentMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AttachmentMessage create() => AttachmentMessage._();
  @$core.override
  AttachmentMessage createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AttachmentMessage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AttachmentMessage>(create);
  static AttachmentMessage? _defaultInstance;

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

  @$pb.TagNumber(2)
  $core.String get text => $_getSZ(1);
  @$pb.TagNumber(2)
  set text($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasText() => $_has(1);
  @$pb.TagNumber(2)
  void clearText() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get mediaUrl => $_getSZ(2);
  @$pb.TagNumber(3)
  set mediaUrl($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMediaUrl() => $_has(2);
  @$pb.TagNumber(3)
  void clearMediaUrl() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get mediaType => $_getSZ(3);
  @$pb.TagNumber(4)
  set mediaType($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMediaType() => $_has(3);
  @$pb.TagNumber(4)
  void clearMediaType() => $_clearField(4);

  @$pb.TagNumber(5)
  MessageStatus get status => $_getN(4);
  @$pb.TagNumber(5)
  set status(MessageStatus value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearStatus() => $_clearField(5);

  @$pb.TagNumber(6)
  MessageRole get role => $_getN(5);
  @$pb.TagNumber(6)
  set role(MessageRole value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasRole() => $_has(5);
  @$pb.TagNumber(6)
  void clearRole() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get byteCount => $_getI64(6);
  @$pb.TagNumber(7)
  set byteCount($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasByteCount() => $_has(6);
  @$pb.TagNumber(7)
  void clearByteCount() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get fileName => $_getSZ(7);
  @$pb.TagNumber(8)
  set fileName($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasFileName() => $_has(7);
  @$pb.TagNumber(8)
  void clearFileName() => $_clearField(8);
}

/// AttachmentMessageRequest is sent by either party to deliver a file attachment.
class AttachmentMessageRequest extends $pb.GeneratedMessage {
  factory AttachmentMessageRequest({
    AttachmentMessage? content,
    $0.Timestamp? timestamp,
    $core.Iterable<$core.String>? quickReplies,
  }) {
    final result = create();
    if (content != null) result.content = content;
    if (timestamp != null) result.timestamp = timestamp;
    if (quickReplies != null) result.quickReplies.addAll(quickReplies);
    return result;
  }

  AttachmentMessageRequest._();

  factory AttachmentMessageRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AttachmentMessageRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AttachmentMessageRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v1'),
      createEmptyInstance: create)
    ..aOM<AttachmentMessage>(1, _omitFieldNames ? '' : 'content',
        subBuilder: AttachmentMessage.create)
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..pPS(3, _omitFieldNames ? '' : 'quickReplies')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AttachmentMessageRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AttachmentMessageRequest copyWith(
          void Function(AttachmentMessageRequest) updates) =>
      super.copyWith((message) => updates(message as AttachmentMessageRequest))
          as AttachmentMessageRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AttachmentMessageRequest create() => AttachmentMessageRequest._();
  @$core.override
  AttachmentMessageRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AttachmentMessageRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AttachmentMessageRequest>(create);
  static AttachmentMessageRequest? _defaultInstance;

  @$pb.TagNumber(1)
  AttachmentMessage get content => $_getN(0);
  @$pb.TagNumber(1)
  set content(AttachmentMessage value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasContent() => $_has(0);
  @$pb.TagNumber(1)
  void clearContent() => $_clearField(1);
  @$pb.TagNumber(1)
  AttachmentMessage ensureContent() => $_ensure(0);

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

/// AttachmentMessageResponse acknowledges an AttachmentMessageRequest and returns the assigned message id.
class AttachmentMessageResponse extends $pb.GeneratedMessage {
  factory AttachmentMessageResponse({
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

  AttachmentMessageResponse._();

  factory AttachmentMessageResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AttachmentMessageResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AttachmentMessageResponse',
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
  AttachmentMessageResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AttachmentMessageResponse copyWith(
          void Function(AttachmentMessageResponse) updates) =>
      super.copyWith((message) => updates(message as AttachmentMessageResponse))
          as AttachmentMessageResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AttachmentMessageResponse create() => AttachmentMessageResponse._();
  @$core.override
  AttachmentMessageResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AttachmentMessageResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AttachmentMessageResponse>(create);
  static AttachmentMessageResponse? _defaultInstance;

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

/// VideoMessage holds the payload of a video conversation turn.
class VideoMessage extends $pb.GeneratedMessage {
  factory VideoMessage({
    $0.Timestamp? timestamp,
    $core.String? text,
    $core.String? mediaUrl,
    $core.String? mediaType,
    MessageStatus? status,
    MessageRole? role,
    $fixnum.Int64? byteCount,
    $core.String? fileName,
    $core.double? duration,
  }) {
    final result = create();
    if (timestamp != null) result.timestamp = timestamp;
    if (text != null) result.text = text;
    if (mediaUrl != null) result.mediaUrl = mediaUrl;
    if (mediaType != null) result.mediaType = mediaType;
    if (status != null) result.status = status;
    if (role != null) result.role = role;
    if (byteCount != null) result.byteCount = byteCount;
    if (fileName != null) result.fileName = fileName;
    if (duration != null) result.duration = duration;
    return result;
  }

  VideoMessage._();

  factory VideoMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory VideoMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'VideoMessage',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v1'),
      createEmptyInstance: create)
    ..aOM<$0.Timestamp>(1, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..aOS(2, _omitFieldNames ? '' : 'text')
    ..aOS(3, _omitFieldNames ? '' : 'mediaUrl')
    ..aOS(4, _omitFieldNames ? '' : 'mediaType')
    ..aE<MessageStatus>(5, _omitFieldNames ? '' : 'status',
        enumValues: MessageStatus.values)
    ..aE<MessageRole>(6, _omitFieldNames ? '' : 'role',
        enumValues: MessageRole.values)
    ..aInt64(7, _omitFieldNames ? '' : 'byteCount')
    ..aOS(8, _omitFieldNames ? '' : 'fileName')
    ..aD(9, _omitFieldNames ? '' : 'duration')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VideoMessage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VideoMessage copyWith(void Function(VideoMessage) updates) =>
      super.copyWith((message) => updates(message as VideoMessage))
          as VideoMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VideoMessage create() => VideoMessage._();
  @$core.override
  VideoMessage createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static VideoMessage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<VideoMessage>(create);
  static VideoMessage? _defaultInstance;

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

  @$pb.TagNumber(2)
  $core.String get text => $_getSZ(1);
  @$pb.TagNumber(2)
  set text($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasText() => $_has(1);
  @$pb.TagNumber(2)
  void clearText() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get mediaUrl => $_getSZ(2);
  @$pb.TagNumber(3)
  set mediaUrl($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMediaUrl() => $_has(2);
  @$pb.TagNumber(3)
  void clearMediaUrl() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get mediaType => $_getSZ(3);
  @$pb.TagNumber(4)
  set mediaType($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMediaType() => $_has(3);
  @$pb.TagNumber(4)
  void clearMediaType() => $_clearField(4);

  @$pb.TagNumber(5)
  MessageStatus get status => $_getN(4);
  @$pb.TagNumber(5)
  set status(MessageStatus value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearStatus() => $_clearField(5);

  @$pb.TagNumber(6)
  MessageRole get role => $_getN(5);
  @$pb.TagNumber(6)
  set role(MessageRole value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasRole() => $_has(5);
  @$pb.TagNumber(6)
  void clearRole() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get byteCount => $_getI64(6);
  @$pb.TagNumber(7)
  set byteCount($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasByteCount() => $_has(6);
  @$pb.TagNumber(7)
  void clearByteCount() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get fileName => $_getSZ(7);
  @$pb.TagNumber(8)
  set fileName($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasFileName() => $_has(7);
  @$pb.TagNumber(8)
  void clearFileName() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.double get duration => $_getN(8);
  @$pb.TagNumber(9)
  set duration($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(9)
  $core.bool hasDuration() => $_has(8);
  @$pb.TagNumber(9)
  void clearDuration() => $_clearField(9);
}

/// VideoMessageRequest is sent by either party to deliver a video.
class VideoMessageRequest extends $pb.GeneratedMessage {
  factory VideoMessageRequest({
    VideoMessage? content,
    $0.Timestamp? timestamp,
    $core.Iterable<$core.String>? quickReplies,
  }) {
    final result = create();
    if (content != null) result.content = content;
    if (timestamp != null) result.timestamp = timestamp;
    if (quickReplies != null) result.quickReplies.addAll(quickReplies);
    return result;
  }

  VideoMessageRequest._();

  factory VideoMessageRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory VideoMessageRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'VideoMessageRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v1'),
      createEmptyInstance: create)
    ..aOM<VideoMessage>(1, _omitFieldNames ? '' : 'content',
        subBuilder: VideoMessage.create)
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..pPS(3, _omitFieldNames ? '' : 'quickReplies')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VideoMessageRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VideoMessageRequest copyWith(void Function(VideoMessageRequest) updates) =>
      super.copyWith((message) => updates(message as VideoMessageRequest))
          as VideoMessageRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VideoMessageRequest create() => VideoMessageRequest._();
  @$core.override
  VideoMessageRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static VideoMessageRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<VideoMessageRequest>(create);
  static VideoMessageRequest? _defaultInstance;

  @$pb.TagNumber(1)
  VideoMessage get content => $_getN(0);
  @$pb.TagNumber(1)
  set content(VideoMessage value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasContent() => $_has(0);
  @$pb.TagNumber(1)
  void clearContent() => $_clearField(1);
  @$pb.TagNumber(1)
  VideoMessage ensureContent() => $_ensure(0);

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

/// VideoMessageResponse acknowledges a VideoMessageRequest and returns the assigned message id.
class VideoMessageResponse extends $pb.GeneratedMessage {
  factory VideoMessageResponse({
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

  VideoMessageResponse._();

  factory VideoMessageResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory VideoMessageResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'VideoMessageResponse',
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
  VideoMessageResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VideoMessageResponse copyWith(void Function(VideoMessageResponse) updates) =>
      super.copyWith((message) => updates(message as VideoMessageResponse))
          as VideoMessageResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VideoMessageResponse create() => VideoMessageResponse._();
  @$core.override
  VideoMessageResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static VideoMessageResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<VideoMessageResponse>(create);
  static VideoMessageResponse? _defaultInstance;

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

/// ButtonsMessage holds the content of a buttons message.
class ButtonsMessage extends $pb.GeneratedMessage {
  factory ButtonsMessage({
    $core.String? header,
    $core.String? body,
    $core.String? footer,
    $core.Iterable<$core.String>? buttons,
  }) {
    final result = create();
    if (header != null) result.header = header;
    if (body != null) result.body = body;
    if (footer != null) result.footer = footer;
    if (buttons != null) result.buttons.addAll(buttons);
    return result;
  }

  ButtonsMessage._();

  factory ButtonsMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ButtonsMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ButtonsMessage',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'header')
    ..aOS(2, _omitFieldNames ? '' : 'body')
    ..aOS(3, _omitFieldNames ? '' : 'footer')
    ..pPS(4, _omitFieldNames ? '' : 'buttons')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ButtonsMessage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ButtonsMessage copyWith(void Function(ButtonsMessage) updates) =>
      super.copyWith((message) => updates(message as ButtonsMessage))
          as ButtonsMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ButtonsMessage create() => ButtonsMessage._();
  @$core.override
  ButtonsMessage createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ButtonsMessage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ButtonsMessage>(create);
  static ButtonsMessage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get header => $_getSZ(0);
  @$pb.TagNumber(1)
  set header($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHeader() => $_has(0);
  @$pb.TagNumber(1)
  void clearHeader() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get body => $_getSZ(1);
  @$pb.TagNumber(2)
  set body($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBody() => $_has(1);
  @$pb.TagNumber(2)
  void clearBody() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get footer => $_getSZ(2);
  @$pb.TagNumber(3)
  set footer($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFooter() => $_has(2);
  @$pb.TagNumber(3)
  void clearFooter() => $_clearField(3);

  /// At least one button text must be provided.
  @$pb.TagNumber(4)
  $pb.PbList<$core.String> get buttons => $_getList(3);
}

/// ButtonsMessageRequest delivers a set of text option buttons to the client UI.
class ButtonsMessageRequest extends $pb.GeneratedMessage {
  factory ButtonsMessageRequest({
    ButtonsMessage? content,
    $0.Timestamp? timestamp,
  }) {
    final result = create();
    if (content != null) result.content = content;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  ButtonsMessageRequest._();

  factory ButtonsMessageRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ButtonsMessageRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ButtonsMessageRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v1'),
      createEmptyInstance: create)
    ..aOM<ButtonsMessage>(1, _omitFieldNames ? '' : 'content',
        subBuilder: ButtonsMessage.create)
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ButtonsMessageRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ButtonsMessageRequest copyWith(
          void Function(ButtonsMessageRequest) updates) =>
      super.copyWith((message) => updates(message as ButtonsMessageRequest))
          as ButtonsMessageRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ButtonsMessageRequest create() => ButtonsMessageRequest._();
  @$core.override
  ButtonsMessageRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ButtonsMessageRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ButtonsMessageRequest>(create);
  static ButtonsMessageRequest? _defaultInstance;

  @$pb.TagNumber(1)
  ButtonsMessage get content => $_getN(0);
  @$pb.TagNumber(1)
  set content(ButtonsMessage value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasContent() => $_has(0);
  @$pb.TagNumber(1)
  void clearContent() => $_clearField(1);
  @$pb.TagNumber(1)
  ButtonsMessage ensureContent() => $_ensure(0);

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

/// ButtonsMessageResponse acknowledges a ButtonsMessageRequest.
class ButtonsMessageResponse extends $pb.GeneratedMessage {
  factory ButtonsMessageResponse({
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

  ButtonsMessageResponse._();

  factory ButtonsMessageResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ButtonsMessageResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ButtonsMessageResponse',
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
  ButtonsMessageResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ButtonsMessageResponse copyWith(
          void Function(ButtonsMessageResponse) updates) =>
      super.copyWith((message) => updates(message as ButtonsMessageResponse))
          as ButtonsMessageResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ButtonsMessageResponse create() => ButtonsMessageResponse._();
  @$core.override
  ButtonsMessageResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ButtonsMessageResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ButtonsMessageResponse>(create);
  static ButtonsMessageResponse? _defaultInstance;

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

/// CTAButton represents a single call-to-action link button.
class CTAButton extends $pb.GeneratedMessage {
  factory CTAButton({
    $core.String? text,
    $core.String? url,
  }) {
    final result = create();
    if (text != null) result.text = text;
    if (url != null) result.url = url;
    return result;
  }

  CTAButton._();

  factory CTAButton.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CTAButton.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CTAButton',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'text')
    ..aOS(2, _omitFieldNames ? '' : 'url')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CTAButton clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CTAButton copyWith(void Function(CTAButton) updates) =>
      super.copyWith((message) => updates(message as CTAButton)) as CTAButton;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CTAButton create() => CTAButton._();
  @$core.override
  CTAButton createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CTAButton getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CTAButton>(create);
  static CTAButton? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get text => $_getSZ(0);
  @$pb.TagNumber(1)
  set text($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasText() => $_has(0);
  @$pb.TagNumber(1)
  void clearText() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get url => $_getSZ(1);
  @$pb.TagNumber(2)
  set url($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUrl() => $_has(1);
  @$pb.TagNumber(2)
  void clearUrl() => $_clearField(2);
}

/// CTAMessage holds the content of a CTA message.
class CTAMessage extends $pb.GeneratedMessage {
  factory CTAMessage({
    $core.String? header,
    $core.String? body,
    $core.String? footer,
    $core.Iterable<CTAButton>? buttons,
  }) {
    final result = create();
    if (header != null) result.header = header;
    if (body != null) result.body = body;
    if (footer != null) result.footer = footer;
    if (buttons != null) result.buttons.addAll(buttons);
    return result;
  }

  CTAMessage._();

  factory CTAMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CTAMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CTAMessage',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'header')
    ..aOS(2, _omitFieldNames ? '' : 'body')
    ..aOS(3, _omitFieldNames ? '' : 'footer')
    ..pPM<CTAButton>(4, _omitFieldNames ? '' : 'buttons',
        subBuilder: CTAButton.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CTAMessage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CTAMessage copyWith(void Function(CTAMessage) updates) =>
      super.copyWith((message) => updates(message as CTAMessage)) as CTAMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CTAMessage create() => CTAMessage._();
  @$core.override
  CTAMessage createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CTAMessage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CTAMessage>(create);
  static CTAMessage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get header => $_getSZ(0);
  @$pb.TagNumber(1)
  set header($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHeader() => $_has(0);
  @$pb.TagNumber(1)
  void clearHeader() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get body => $_getSZ(1);
  @$pb.TagNumber(2)
  set body($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBody() => $_has(1);
  @$pb.TagNumber(2)
  void clearBody() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get footer => $_getSZ(2);
  @$pb.TagNumber(3)
  set footer($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFooter() => $_has(2);
  @$pb.TagNumber(3)
  void clearFooter() => $_clearField(3);

  /// At least one CTA button must be provided.
  @$pb.TagNumber(4)
  $pb.PbList<CTAButton> get buttons => $_getList(3);
}

/// CTAMessageRequest delivers a set of link buttons to the client UI.
class CTAMessageRequest extends $pb.GeneratedMessage {
  factory CTAMessageRequest({
    CTAMessage? content,
    $0.Timestamp? timestamp,
  }) {
    final result = create();
    if (content != null) result.content = content;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  CTAMessageRequest._();

  factory CTAMessageRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CTAMessageRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CTAMessageRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v1'),
      createEmptyInstance: create)
    ..aOM<CTAMessage>(1, _omitFieldNames ? '' : 'content',
        subBuilder: CTAMessage.create)
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CTAMessageRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CTAMessageRequest copyWith(void Function(CTAMessageRequest) updates) =>
      super.copyWith((message) => updates(message as CTAMessageRequest))
          as CTAMessageRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CTAMessageRequest create() => CTAMessageRequest._();
  @$core.override
  CTAMessageRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CTAMessageRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CTAMessageRequest>(create);
  static CTAMessageRequest? _defaultInstance;

  @$pb.TagNumber(1)
  CTAMessage get content => $_getN(0);
  @$pb.TagNumber(1)
  set content(CTAMessage value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasContent() => $_has(0);
  @$pb.TagNumber(1)
  void clearContent() => $_clearField(1);
  @$pb.TagNumber(1)
  CTAMessage ensureContent() => $_ensure(0);

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

/// CTAMessageResponse acknowledges a CTAMessageRequest.
class CTAMessageResponse extends $pb.GeneratedMessage {
  factory CTAMessageResponse({
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

  CTAMessageResponse._();

  factory CTAMessageResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CTAMessageResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CTAMessageResponse',
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
  CTAMessageResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CTAMessageResponse copyWith(void Function(CTAMessageResponse) updates) =>
      super.copyWith((message) => updates(message as CTAMessageResponse))
          as CTAMessageResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CTAMessageResponse create() => CTAMessageResponse._();
  @$core.override
  CTAMessageResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CTAMessageResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CTAMessageResponse>(create);
  static CTAMessageResponse? _defaultInstance;

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

/// AuthRequest is the body of POST /auth used to obtain an initial access token.
class AuthRequest extends $pb.GeneratedMessage {
  factory AuthRequest({
    $core.String? userType,
    $core.String? channelId,
    $core.String? organizationId,
    $fixnum.Int64? timestamp,
  }) {
    final result = create();
    if (userType != null) result.userType = userType;
    if (channelId != null) result.channelId = channelId;
    if (organizationId != null) result.organizationId = organizationId;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  AuthRequest._();

  factory AuthRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AuthRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AuthRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userType')
    ..aOS(2, _omitFieldNames ? '' : 'channelId')
    ..aOS(3, _omitFieldNames ? '' : 'organizationId')
    ..aInt64(4, _omitFieldNames ? '' : 'timestamp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AuthRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AuthRequest copyWith(void Function(AuthRequest) updates) =>
      super.copyWith((message) => updates(message as AuthRequest))
          as AuthRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AuthRequest create() => AuthRequest._();
  @$core.override
  AuthRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AuthRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AuthRequest>(create);
  static AuthRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userType => $_getSZ(0);
  @$pb.TagNumber(1)
  set userType($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserType() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get channelId => $_getSZ(1);
  @$pb.TagNumber(2)
  set channelId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasChannelId() => $_has(1);
  @$pb.TagNumber(2)
  void clearChannelId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get organizationId => $_getSZ(2);
  @$pb.TagNumber(3)
  set organizationId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOrganizationId() => $_has(2);
  @$pb.TagNumber(3)
  void clearOrganizationId() => $_clearField(3);

  /// Unix timestamp in seconds.
  @$pb.TagNumber(4)
  $fixnum.Int64 get timestamp => $_getI64(3);
  @$pb.TagNumber(4)
  set timestamp($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTimestamp() => $_has(3);
  @$pb.TagNumber(4)
  void clearTimestamp() => $_clearField(4);
}

/// RefreshTokenRequest is the body of POST /oauth/token used to refresh an
/// expired access token via the refresh_token grant.
class RefreshTokenRequest extends $pb.GeneratedMessage {
  factory RefreshTokenRequest({
    $core.String? grantType,
    $core.String? refreshToken,
  }) {
    final result = create();
    if (grantType != null) result.grantType = grantType;
    if (refreshToken != null) result.refreshToken = refreshToken;
    return result;
  }

  RefreshTokenRequest._();

  factory RefreshTokenRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RefreshTokenRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RefreshTokenRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'grantType')
    ..aOS(2, _omitFieldNames ? '' : 'refreshToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RefreshTokenRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RefreshTokenRequest copyWith(void Function(RefreshTokenRequest) updates) =>
      super.copyWith((message) => updates(message as RefreshTokenRequest))
          as RefreshTokenRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RefreshTokenRequest create() => RefreshTokenRequest._();
  @$core.override
  RefreshTokenRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RefreshTokenRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RefreshTokenRequest>(create);
  static RefreshTokenRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get grantType => $_getSZ(0);
  @$pb.TagNumber(1)
  set grantType($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasGrantType() => $_has(0);
  @$pb.TagNumber(1)
  void clearGrantType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get refreshToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set refreshToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRefreshToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearRefreshToken() => $_clearField(2);
}

/// AuthResponse is returned by both POST /auth and POST /oauth/token.
class AuthResponse extends $pb.GeneratedMessage {
  factory AuthResponse({
    $core.String? accessToken,
    $core.String? tokenType,
    $fixnum.Int64? expiresIn,
    $core.String? refreshToken,
    $core.String? clientId,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (tokenType != null) result.tokenType = tokenType;
    if (expiresIn != null) result.expiresIn = expiresIn;
    if (refreshToken != null) result.refreshToken = refreshToken;
    if (clientId != null) result.clientId = clientId;
    return result;
  }

  AuthResponse._();

  factory AuthResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AuthResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AuthResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOS(2, _omitFieldNames ? '' : 'tokenType')
    ..aInt64(3, _omitFieldNames ? '' : 'expiresIn')
    ..aOS(4, _omitFieldNames ? '' : 'refreshToken')
    ..aOS(5, _omitFieldNames ? '' : 'clientId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AuthResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AuthResponse copyWith(void Function(AuthResponse) updates) =>
      super.copyWith((message) => updates(message as AuthResponse))
          as AuthResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AuthResponse create() => AuthResponse._();
  @$core.override
  AuthResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AuthResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AuthResponse>(create);
  static AuthResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get tokenType => $_getSZ(1);
  @$pb.TagNumber(2)
  set tokenType($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTokenType() => $_has(1);
  @$pb.TagNumber(2)
  void clearTokenType() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get expiresIn => $_getI64(2);
  @$pb.TagNumber(3)
  set expiresIn($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasExpiresIn() => $_has(2);
  @$pb.TagNumber(3)
  void clearExpiresIn() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get refreshToken => $_getSZ(3);
  @$pb.TagNumber(4)
  set refreshToken($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRefreshToken() => $_has(3);
  @$pb.TagNumber(4)
  void clearRefreshToken() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get clientId => $_getSZ(4);
  @$pb.TagNumber(5)
  set clientId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasClientId() => $_has(4);
  @$pb.TagNumber(5)
  void clearClientId() => $_clearField(5);
}

/// PollMessageItem represents a single message entry returned by the message
/// poll endpoint. The message field reuses SdkMessage so all payload types
/// (text, image, voice, etc.) are supported without duplication.
class PollMessageItem extends $pb.GeneratedMessage {
  factory PollMessageItem({
    $core.String? id,
    SdkMessage? message,
    $0.Timestamp? date,
    $core.String? userId,
    $core.String? status,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (message != null) result.message = message;
    if (date != null) result.date = date;
    if (userId != null) result.userId = userId;
    if (status != null) result.status = status;
    return result;
  }

  PollMessageItem._();

  factory PollMessageItem.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PollMessageItem.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PollMessageItem',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOM<SdkMessage>(2, _omitFieldNames ? '' : 'message',
        subBuilder: SdkMessage.create)
    ..aOM<$0.Timestamp>(3, _omitFieldNames ? '' : 'date',
        subBuilder: $0.Timestamp.create)
    ..aOS(4, _omitFieldNames ? '' : 'userId')
    ..aOS(5, _omitFieldNames ? '' : 'status')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PollMessageItem clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PollMessageItem copyWith(void Function(PollMessageItem) updates) =>
      super.copyWith((message) => updates(message as PollMessageItem))
          as PollMessageItem;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PollMessageItem create() => PollMessageItem._();
  @$core.override
  PollMessageItem createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PollMessageItem getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PollMessageItem>(create);
  static PollMessageItem? _defaultInstance;

  /// Server-assigned unique identifier for this poll entry.
  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  /// The SDK message payload, including its timestamp and oneof payload.
  @$pb.TagNumber(2)
  SdkMessage get message => $_getN(1);
  @$pb.TagNumber(2)
  set message(SdkMessage value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);
  @$pb.TagNumber(2)
  SdkMessage ensureMessage() => $_ensure(1);

  /// Wall-clock time at which the message was recorded on the server.
  @$pb.TagNumber(3)
  $0.Timestamp get date => $_getN(2);
  @$pb.TagNumber(3)
  set date($0.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasDate() => $_has(2);
  @$pb.TagNumber(3)
  void clearDate() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.Timestamp ensureDate() => $_ensure(2);

  /// Identifier of the user associated with this message.
  @$pb.TagNumber(4)
  $core.String get userId => $_getSZ(3);
  @$pb.TagNumber(4)
  set userId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasUserId() => $_has(3);
  @$pb.TagNumber(4)
  void clearUserId() => $_clearField(4);

  /// Current delivery status of the message.
  @$pb.TagNumber(5)
  $core.String get status => $_getSZ(4);
  @$pb.TagNumber(5)
  set status($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearStatus() => $_clearField(5);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
