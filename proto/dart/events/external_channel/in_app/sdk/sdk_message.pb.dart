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
  voiceNoteMessageRequest,
  imageMessageRequest,
  messageReceiptRequest,
  attachmentMessageRequest,
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
  customCommandRequest,
  customCommandResponse,
  videoMessageRequest,
  updateCartProductRequest,
  updateCartProductResponse,
  productConfirmationMessageRequest,
  productConfirmationMessageResponse,
  getCartRequest,
  getCartResponse,
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
    VoiceNoteMessageRequest? voiceNoteMessageRequest,
    ImageMessageRequest? imageMessageRequest,
    MessageReceiptRequest? messageReceiptRequest,
    AttachmentMessageRequest? attachmentMessageRequest,
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
    CustomCommandRequest? customCommandRequest,
    CustomCommandResponse? customCommandResponse,
    VideoMessageRequest? videoMessageRequest,
    UpdateCartProductRequest? updateCartProductRequest,
    UpdateCartProductResponse? updateCartProductResponse,
    ProductConfirmationMessageRequest? productConfirmationMessageRequest,
    ProductConfirmationMessageResponse? productConfirmationMessageResponse,
    GetCartRequest? getCartRequest,
    GetCartResponse? getCartResponse,
  }) {
    final result = SdkMessage._();
    if (correlationId != null) result.correlationId = correlationId;
    if (timestamp != null) result.timestamp = timestamp;
    if (textMessageRequest != null)
      result.textMessageRequest = textMessageRequest;
    if (voiceNoteMessageRequest != null)
      result.voiceNoteMessageRequest = voiceNoteMessageRequest;
    if (imageMessageRequest != null)
      result.imageMessageRequest = imageMessageRequest;
    if (messageReceiptRequest != null)
      result.messageReceiptRequest = messageReceiptRequest;
    if (attachmentMessageRequest != null)
      result.attachmentMessageRequest = attachmentMessageRequest;
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
    if (customCommandRequest != null)
      result.customCommandRequest = customCommandRequest;
    if (customCommandResponse != null)
      result.customCommandResponse = customCommandResponse;
    if (videoMessageRequest != null)
      result.videoMessageRequest = videoMessageRequest;
    if (updateCartProductRequest != null)
      result.updateCartProductRequest = updateCartProductRequest;
    if (updateCartProductResponse != null)
      result.updateCartProductResponse = updateCartProductResponse;
    if (productConfirmationMessageRequest != null)
      result.productConfirmationMessageRequest =
          productConfirmationMessageRequest;
    if (productConfirmationMessageResponse != null)
      result.productConfirmationMessageResponse =
          productConfirmationMessageResponse;
    if (getCartRequest != null) result.getCartRequest = getCartRequest;
    if (getCartResponse != null) result.getCartResponse = getCartResponse;
    return result;
  }

  SdkMessage._();

  factory SdkMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SdkMessage()..mergeFromBuffer(data, registry);
  factory SdkMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SdkMessage()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, SdkMessage_Payload>
      _SdkMessage_PayloadByTag = {
    10: SdkMessage_Payload.textMessageRequest,
    12: SdkMessage_Payload.voiceNoteMessageRequest,
    14: SdkMessage_Payload.imageMessageRequest,
    16: SdkMessage_Payload.messageReceiptRequest,
    18: SdkMessage_Payload.attachmentMessageRequest,
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
    36: SdkMessage_Payload.customCommandRequest,
    37: SdkMessage_Payload.customCommandResponse,
    38: SdkMessage_Payload.videoMessageRequest,
    46: SdkMessage_Payload.updateCartProductRequest,
    47: SdkMessage_Payload.updateCartProductResponse,
    48: SdkMessage_Payload.productConfirmationMessageRequest,
    49: SdkMessage_Payload.productConfirmationMessageResponse,
    50: SdkMessage_Payload.getCartRequest,
    51: SdkMessage_Payload.getCartResponse,
    0: SdkMessage_Payload.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SdkMessage',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v2'),
      createEmptyInstance: SdkMessage.$_createMessage)
    ..oo(0, [
      10,
      12,
      14,
      16,
      18,
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
      46,
      47,
      48,
      49,
      50,
      51
    ])
    ..aOS(1, _omitFieldNames ? '' : 'correlationId')
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.$_createMessage)
    ..aOM<TextMessageRequest>(10, _omitFieldNames ? '' : 'textMessageRequest',
        subBuilder: TextMessageRequest.$_createMessage)
    ..aOM<VoiceNoteMessageRequest>(
        12, _omitFieldNames ? '' : 'voiceNoteMessageRequest',
        subBuilder: VoiceNoteMessageRequest.$_createMessage)
    ..aOM<ImageMessageRequest>(14, _omitFieldNames ? '' : 'imageMessageRequest',
        subBuilder: ImageMessageRequest.$_createMessage)
    ..aOM<MessageReceiptRequest>(
        16, _omitFieldNames ? '' : 'messageReceiptRequest',
        subBuilder: MessageReceiptRequest.$_createMessage)
    ..aOM<AttachmentMessageRequest>(
        18, _omitFieldNames ? '' : 'attachmentMessageRequest',
        subBuilder: AttachmentMessageRequest.$_createMessage)
    ..aOM<AddToCartRequest>(20, _omitFieldNames ? '' : 'addToCartRequest',
        subBuilder: AddToCartRequest.$_createMessage)
    ..aOM<AddToCartResponse>(21, _omitFieldNames ? '' : 'addToCartResponse',
        subBuilder: AddToCartResponse.$_createMessage)
    ..aOM<RemoveFromCartRequest>(
        22, _omitFieldNames ? '' : 'removeFromCartRequest',
        subBuilder: RemoveFromCartRequest.$_createMessage)
    ..aOM<RemoveFromCartResponse>(
        23, _omitFieldNames ? '' : 'removeFromCartResponse',
        subBuilder: RemoveFromCartResponse.$_createMessage)
    ..aOM<ClearCartRequest>(24, _omitFieldNames ? '' : 'clearCartRequest',
        subBuilder: ClearCartRequest.$_createMessage)
    ..aOM<ClearCartResponse>(25, _omitFieldNames ? '' : 'clearCartResponse',
        subBuilder: ClearCartResponse.$_createMessage)
    ..aOM<GuidanceCardRequest>(26, _omitFieldNames ? '' : 'guidanceCardRequest',
        subBuilder: GuidanceCardRequest.$_createMessage)
    ..aOM<GuidanceCardResponse>(
        27, _omitFieldNames ? '' : 'guidanceCardResponse',
        subBuilder: GuidanceCardResponse.$_createMessage)
    ..aOM<AddPromotionRequest>(28, _omitFieldNames ? '' : 'addPromotionRequest',
        subBuilder: AddPromotionRequest.$_createMessage)
    ..aOM<AddPromotionResponse>(
        29, _omitFieldNames ? '' : 'addPromotionResponse',
        subBuilder: AddPromotionResponse.$_createMessage)
    ..aOM<PromotionMessageRequest>(
        30, _omitFieldNames ? '' : 'promotionMessageRequest',
        subBuilder: PromotionMessageRequest.$_createMessage)
    ..aOM<PromotionMessageResponse>(
        31, _omitFieldNames ? '' : 'promotionMessageResponse',
        subBuilder: PromotionMessageResponse.$_createMessage)
    ..aOM<ProductMessageRequest>(
        32, _omitFieldNames ? '' : 'productMessageRequest',
        subBuilder: ProductMessageRequest.$_createMessage)
    ..aOM<ProductMessageResponse>(
        33, _omitFieldNames ? '' : 'productMessageResponse',
        subBuilder: ProductMessageResponse.$_createMessage)
    ..aOM<ChatStatusRequest>(34, _omitFieldNames ? '' : 'chatStatusRequest',
        subBuilder: ChatStatusRequest.$_createMessage)
    ..aOM<ChatStatusResponse>(35, _omitFieldNames ? '' : 'chatStatusResponse',
        subBuilder: ChatStatusResponse.$_createMessage)
    ..aOM<CustomCommandRequest>(
        36, _omitFieldNames ? '' : 'customCommandRequest',
        subBuilder: CustomCommandRequest.$_createMessage)
    ..aOM<CustomCommandResponse>(
        37, _omitFieldNames ? '' : 'customCommandResponse',
        subBuilder: CustomCommandResponse.$_createMessage)
    ..aOM<VideoMessageRequest>(38, _omitFieldNames ? '' : 'videoMessageRequest',
        subBuilder: VideoMessageRequest.$_createMessage)
    ..aOM<UpdateCartProductRequest>(
        46, _omitFieldNames ? '' : 'updateCartProductRequest',
        subBuilder: UpdateCartProductRequest.$_createMessage)
    ..aOM<UpdateCartProductResponse>(
        47, _omitFieldNames ? '' : 'updateCartProductResponse',
        subBuilder: UpdateCartProductResponse.$_createMessage)
    ..aOM<ProductConfirmationMessageRequest>(
        48, _omitFieldNames ? '' : 'productConfirmationMessageRequest',
        subBuilder: ProductConfirmationMessageRequest.$_createMessage)
    ..aOM<ProductConfirmationMessageResponse>(
        49, _omitFieldNames ? '' : 'productConfirmationMessageResponse',
        subBuilder: ProductConfirmationMessageResponse.$_createMessage)
    ..aOM<GetCartRequest>(50, _omitFieldNames ? '' : 'getCartRequest',
        subBuilder: GetCartRequest.$_createMessage)
    ..aOM<GetCartResponse>(51, _omitFieldNames ? '' : 'getCartResponse',
        subBuilder: GetCartResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SdkMessage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SdkMessage copyWith(void Function(SdkMessage) updates) =>
      super.copyWith((message) => updates(message as SdkMessage)) as SdkMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SdkMessage() / SdkMessage.new instead')
  static SdkMessage create() => SdkMessage._();
  static $pb.GeneratedMessage $_createMessage() => SdkMessage._();
  @$core.override
  SdkMessage createEmptyInstance() => SdkMessage._();
  @$core.pragma('dart2js:noInline')
  static SdkMessage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SdkMessage>(SdkMessage.$_createMessage);
  static SdkMessage? _defaultInstance;

  @$pb.TagNumber(10)
  @$pb.TagNumber(12)
  @$pb.TagNumber(14)
  @$pb.TagNumber(16)
  @$pb.TagNumber(18)
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
  @$pb.TagNumber(46)
  @$pb.TagNumber(47)
  @$pb.TagNumber(48)
  @$pb.TagNumber(49)
  @$pb.TagNumber(50)
  @$pb.TagNumber(51)
  SdkMessage_Payload whichPayload() =>
      _SdkMessage_PayloadByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(10)
  @$pb.TagNumber(12)
  @$pb.TagNumber(14)
  @$pb.TagNumber(16)
  @$pb.TagNumber(18)
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
  @$pb.TagNumber(46)
  @$pb.TagNumber(47)
  @$pb.TagNumber(48)
  @$pb.TagNumber(49)
  @$pb.TagNumber(50)
  @$pb.TagNumber(51)
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

  @$pb.TagNumber(12)
  VoiceNoteMessageRequest get voiceNoteMessageRequest => $_getN(3);
  @$pb.TagNumber(12)
  set voiceNoteMessageRequest(VoiceNoteMessageRequest value) =>
      $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasVoiceNoteMessageRequest() => $_has(3);
  @$pb.TagNumber(12)
  void clearVoiceNoteMessageRequest() => $_clearField(12);
  @$pb.TagNumber(12)
  VoiceNoteMessageRequest ensureVoiceNoteMessageRequest() => $_ensure(3);

  @$pb.TagNumber(14)
  ImageMessageRequest get imageMessageRequest => $_getN(4);
  @$pb.TagNumber(14)
  set imageMessageRequest(ImageMessageRequest value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasImageMessageRequest() => $_has(4);
  @$pb.TagNumber(14)
  void clearImageMessageRequest() => $_clearField(14);
  @$pb.TagNumber(14)
  ImageMessageRequest ensureImageMessageRequest() => $_ensure(4);

  @$pb.TagNumber(16)
  MessageReceiptRequest get messageReceiptRequest => $_getN(5);
  @$pb.TagNumber(16)
  set messageReceiptRequest(MessageReceiptRequest value) =>
      $_setField(16, value);
  @$pb.TagNumber(16)
  $core.bool hasMessageReceiptRequest() => $_has(5);
  @$pb.TagNumber(16)
  void clearMessageReceiptRequest() => $_clearField(16);
  @$pb.TagNumber(16)
  MessageReceiptRequest ensureMessageReceiptRequest() => $_ensure(5);

  @$pb.TagNumber(18)
  AttachmentMessageRequest get attachmentMessageRequest => $_getN(6);
  @$pb.TagNumber(18)
  set attachmentMessageRequest(AttachmentMessageRequest value) =>
      $_setField(18, value);
  @$pb.TagNumber(18)
  $core.bool hasAttachmentMessageRequest() => $_has(6);
  @$pb.TagNumber(18)
  void clearAttachmentMessageRequest() => $_clearField(18);
  @$pb.TagNumber(18)
  AttachmentMessageRequest ensureAttachmentMessageRequest() => $_ensure(6);

  @$pb.TagNumber(20)
  AddToCartRequest get addToCartRequest => $_getN(7);
  @$pb.TagNumber(20)
  set addToCartRequest(AddToCartRequest value) => $_setField(20, value);
  @$pb.TagNumber(20)
  $core.bool hasAddToCartRequest() => $_has(7);
  @$pb.TagNumber(20)
  void clearAddToCartRequest() => $_clearField(20);
  @$pb.TagNumber(20)
  AddToCartRequest ensureAddToCartRequest() => $_ensure(7);

  @$pb.TagNumber(21)
  AddToCartResponse get addToCartResponse => $_getN(8);
  @$pb.TagNumber(21)
  set addToCartResponse(AddToCartResponse value) => $_setField(21, value);
  @$pb.TagNumber(21)
  $core.bool hasAddToCartResponse() => $_has(8);
  @$pb.TagNumber(21)
  void clearAddToCartResponse() => $_clearField(21);
  @$pb.TagNumber(21)
  AddToCartResponse ensureAddToCartResponse() => $_ensure(8);

  @$pb.TagNumber(22)
  RemoveFromCartRequest get removeFromCartRequest => $_getN(9);
  @$pb.TagNumber(22)
  set removeFromCartRequest(RemoveFromCartRequest value) =>
      $_setField(22, value);
  @$pb.TagNumber(22)
  $core.bool hasRemoveFromCartRequest() => $_has(9);
  @$pb.TagNumber(22)
  void clearRemoveFromCartRequest() => $_clearField(22);
  @$pb.TagNumber(22)
  RemoveFromCartRequest ensureRemoveFromCartRequest() => $_ensure(9);

  @$pb.TagNumber(23)
  RemoveFromCartResponse get removeFromCartResponse => $_getN(10);
  @$pb.TagNumber(23)
  set removeFromCartResponse(RemoveFromCartResponse value) =>
      $_setField(23, value);
  @$pb.TagNumber(23)
  $core.bool hasRemoveFromCartResponse() => $_has(10);
  @$pb.TagNumber(23)
  void clearRemoveFromCartResponse() => $_clearField(23);
  @$pb.TagNumber(23)
  RemoveFromCartResponse ensureRemoveFromCartResponse() => $_ensure(10);

  @$pb.TagNumber(24)
  ClearCartRequest get clearCartRequest => $_getN(11);
  @$pb.TagNumber(24)
  set clearCartRequest(ClearCartRequest value) => $_setField(24, value);
  @$pb.TagNumber(24)
  $core.bool hasClearCartRequest() => $_has(11);
  @$pb.TagNumber(24)
  void clearClearCartRequest() => $_clearField(24);
  @$pb.TagNumber(24)
  ClearCartRequest ensureClearCartRequest() => $_ensure(11);

  @$pb.TagNumber(25)
  ClearCartResponse get clearCartResponse => $_getN(12);
  @$pb.TagNumber(25)
  set clearCartResponse(ClearCartResponse value) => $_setField(25, value);
  @$pb.TagNumber(25)
  $core.bool hasClearCartResponse() => $_has(12);
  @$pb.TagNumber(25)
  void clearClearCartResponse() => $_clearField(25);
  @$pb.TagNumber(25)
  ClearCartResponse ensureClearCartResponse() => $_ensure(12);

  /// Client → channel
  @$pb.TagNumber(26)
  GuidanceCardRequest get guidanceCardRequest => $_getN(13);
  @$pb.TagNumber(26)
  set guidanceCardRequest(GuidanceCardRequest value) => $_setField(26, value);
  @$pb.TagNumber(26)
  $core.bool hasGuidanceCardRequest() => $_has(13);
  @$pb.TagNumber(26)
  void clearGuidanceCardRequest() => $_clearField(26);
  @$pb.TagNumber(26)
  GuidanceCardRequest ensureGuidanceCardRequest() => $_ensure(13);

  @$pb.TagNumber(27)
  GuidanceCardResponse get guidanceCardResponse => $_getN(14);
  @$pb.TagNumber(27)
  set guidanceCardResponse(GuidanceCardResponse value) => $_setField(27, value);
  @$pb.TagNumber(27)
  $core.bool hasGuidanceCardResponse() => $_has(14);
  @$pb.TagNumber(27)
  void clearGuidanceCardResponse() => $_clearField(27);
  @$pb.TagNumber(27)
  GuidanceCardResponse ensureGuidanceCardResponse() => $_ensure(14);

  @$pb.TagNumber(28)
  AddPromotionRequest get addPromotionRequest => $_getN(15);
  @$pb.TagNumber(28)
  set addPromotionRequest(AddPromotionRequest value) => $_setField(28, value);
  @$pb.TagNumber(28)
  $core.bool hasAddPromotionRequest() => $_has(15);
  @$pb.TagNumber(28)
  void clearAddPromotionRequest() => $_clearField(28);
  @$pb.TagNumber(28)
  AddPromotionRequest ensureAddPromotionRequest() => $_ensure(15);

  @$pb.TagNumber(29)
  AddPromotionResponse get addPromotionResponse => $_getN(16);
  @$pb.TagNumber(29)
  set addPromotionResponse(AddPromotionResponse value) => $_setField(29, value);
  @$pb.TagNumber(29)
  $core.bool hasAddPromotionResponse() => $_has(16);
  @$pb.TagNumber(29)
  void clearAddPromotionResponse() => $_clearField(29);
  @$pb.TagNumber(29)
  AddPromotionResponse ensureAddPromotionResponse() => $_ensure(16);

  /// Channel → client
  @$pb.TagNumber(30)
  PromotionMessageRequest get promotionMessageRequest => $_getN(17);
  @$pb.TagNumber(30)
  set promotionMessageRequest(PromotionMessageRequest value) =>
      $_setField(30, value);
  @$pb.TagNumber(30)
  $core.bool hasPromotionMessageRequest() => $_has(17);
  @$pb.TagNumber(30)
  void clearPromotionMessageRequest() => $_clearField(30);
  @$pb.TagNumber(30)
  PromotionMessageRequest ensurePromotionMessageRequest() => $_ensure(17);

  @$pb.TagNumber(31)
  PromotionMessageResponse get promotionMessageResponse => $_getN(18);
  @$pb.TagNumber(31)
  set promotionMessageResponse(PromotionMessageResponse value) =>
      $_setField(31, value);
  @$pb.TagNumber(31)
  $core.bool hasPromotionMessageResponse() => $_has(18);
  @$pb.TagNumber(31)
  void clearPromotionMessageResponse() => $_clearField(31);
  @$pb.TagNumber(31)
  PromotionMessageResponse ensurePromotionMessageResponse() => $_ensure(18);

  @$pb.TagNumber(32)
  ProductMessageRequest get productMessageRequest => $_getN(19);
  @$pb.TagNumber(32)
  set productMessageRequest(ProductMessageRequest value) =>
      $_setField(32, value);
  @$pb.TagNumber(32)
  $core.bool hasProductMessageRequest() => $_has(19);
  @$pb.TagNumber(32)
  void clearProductMessageRequest() => $_clearField(32);
  @$pb.TagNumber(32)
  ProductMessageRequest ensureProductMessageRequest() => $_ensure(19);

  @$pb.TagNumber(33)
  ProductMessageResponse get productMessageResponse => $_getN(20);
  @$pb.TagNumber(33)
  set productMessageResponse(ProductMessageResponse value) =>
      $_setField(33, value);
  @$pb.TagNumber(33)
  $core.bool hasProductMessageResponse() => $_has(20);
  @$pb.TagNumber(33)
  void clearProductMessageResponse() => $_clearField(33);
  @$pb.TagNumber(33)
  ProductMessageResponse ensureProductMessageResponse() => $_ensure(20);

  @$pb.TagNumber(34)
  ChatStatusRequest get chatStatusRequest => $_getN(21);
  @$pb.TagNumber(34)
  set chatStatusRequest(ChatStatusRequest value) => $_setField(34, value);
  @$pb.TagNumber(34)
  $core.bool hasChatStatusRequest() => $_has(21);
  @$pb.TagNumber(34)
  void clearChatStatusRequest() => $_clearField(34);
  @$pb.TagNumber(34)
  ChatStatusRequest ensureChatStatusRequest() => $_ensure(21);

  @$pb.TagNumber(35)
  ChatStatusResponse get chatStatusResponse => $_getN(22);
  @$pb.TagNumber(35)
  set chatStatusResponse(ChatStatusResponse value) => $_setField(35, value);
  @$pb.TagNumber(35)
  $core.bool hasChatStatusResponse() => $_has(22);
  @$pb.TagNumber(35)
  void clearChatStatusResponse() => $_clearField(35);
  @$pb.TagNumber(35)
  ChatStatusResponse ensureChatStatusResponse() => $_ensure(22);

  @$pb.TagNumber(36)
  CustomCommandRequest get customCommandRequest => $_getN(23);
  @$pb.TagNumber(36)
  set customCommandRequest(CustomCommandRequest value) => $_setField(36, value);
  @$pb.TagNumber(36)
  $core.bool hasCustomCommandRequest() => $_has(23);
  @$pb.TagNumber(36)
  void clearCustomCommandRequest() => $_clearField(36);
  @$pb.TagNumber(36)
  CustomCommandRequest ensureCustomCommandRequest() => $_ensure(23);

  @$pb.TagNumber(37)
  CustomCommandResponse get customCommandResponse => $_getN(24);
  @$pb.TagNumber(37)
  set customCommandResponse(CustomCommandResponse value) =>
      $_setField(37, value);
  @$pb.TagNumber(37)
  $core.bool hasCustomCommandResponse() => $_has(24);
  @$pb.TagNumber(37)
  void clearCustomCommandResponse() => $_clearField(37);
  @$pb.TagNumber(37)
  CustomCommandResponse ensureCustomCommandResponse() => $_ensure(24);

  @$pb.TagNumber(38)
  VideoMessageRequest get videoMessageRequest => $_getN(25);
  @$pb.TagNumber(38)
  set videoMessageRequest(VideoMessageRequest value) => $_setField(38, value);
  @$pb.TagNumber(38)
  $core.bool hasVideoMessageRequest() => $_has(25);
  @$pb.TagNumber(38)
  void clearVideoMessageRequest() => $_clearField(38);
  @$pb.TagNumber(38)
  VideoMessageRequest ensureVideoMessageRequest() => $_ensure(25);

  @$pb.TagNumber(46)
  UpdateCartProductRequest get updateCartProductRequest => $_getN(26);
  @$pb.TagNumber(46)
  set updateCartProductRequest(UpdateCartProductRequest value) =>
      $_setField(46, value);
  @$pb.TagNumber(46)
  $core.bool hasUpdateCartProductRequest() => $_has(26);
  @$pb.TagNumber(46)
  void clearUpdateCartProductRequest() => $_clearField(46);
  @$pb.TagNumber(46)
  UpdateCartProductRequest ensureUpdateCartProductRequest() => $_ensure(26);

  @$pb.TagNumber(47)
  UpdateCartProductResponse get updateCartProductResponse => $_getN(27);
  @$pb.TagNumber(47)
  set updateCartProductResponse(UpdateCartProductResponse value) =>
      $_setField(47, value);
  @$pb.TagNumber(47)
  $core.bool hasUpdateCartProductResponse() => $_has(27);
  @$pb.TagNumber(47)
  void clearUpdateCartProductResponse() => $_clearField(47);
  @$pb.TagNumber(47)
  UpdateCartProductResponse ensureUpdateCartProductResponse() => $_ensure(27);

  @$pb.TagNumber(48)
  ProductConfirmationMessageRequest get productConfirmationMessageRequest =>
      $_getN(28);
  @$pb.TagNumber(48)
  set productConfirmationMessageRequest(
          ProductConfirmationMessageRequest value) =>
      $_setField(48, value);
  @$pb.TagNumber(48)
  $core.bool hasProductConfirmationMessageRequest() => $_has(28);
  @$pb.TagNumber(48)
  void clearProductConfirmationMessageRequest() => $_clearField(48);
  @$pb.TagNumber(48)
  ProductConfirmationMessageRequest ensureProductConfirmationMessageRequest() =>
      $_ensure(28);

  @$pb.TagNumber(49)
  ProductConfirmationMessageResponse get productConfirmationMessageResponse =>
      $_getN(29);
  @$pb.TagNumber(49)
  set productConfirmationMessageResponse(
          ProductConfirmationMessageResponse value) =>
      $_setField(49, value);
  @$pb.TagNumber(49)
  $core.bool hasProductConfirmationMessageResponse() => $_has(29);
  @$pb.TagNumber(49)
  void clearProductConfirmationMessageResponse() => $_clearField(49);
  @$pb.TagNumber(49)
  ProductConfirmationMessageResponse
      ensureProductConfirmationMessageResponse() => $_ensure(29);

  @$pb.TagNumber(50)
  GetCartRequest get getCartRequest => $_getN(30);
  @$pb.TagNumber(50)
  set getCartRequest(GetCartRequest value) => $_setField(50, value);
  @$pb.TagNumber(50)
  $core.bool hasGetCartRequest() => $_has(30);
  @$pb.TagNumber(50)
  void clearGetCartRequest() => $_clearField(50);
  @$pb.TagNumber(50)
  GetCartRequest ensureGetCartRequest() => $_ensure(30);

  @$pb.TagNumber(51)
  GetCartResponse get getCartResponse => $_getN(31);
  @$pb.TagNumber(51)
  set getCartResponse(GetCartResponse value) => $_setField(51, value);
  @$pb.TagNumber(51)
  $core.bool hasGetCartResponse() => $_has(31);
  @$pb.TagNumber(51)
  void clearGetCartResponse() => $_clearField(51);
  @$pb.TagNumber(51)
  GetCartResponse ensureGetCartResponse() => $_ensure(31);
}

/// Button represents a single tappable option attached to a message.
/// url is required when button_type is BUTTON_TYPE_LINK and ignored otherwise.
class Button extends $pb.GeneratedMessage {
  factory Button({
    $core.String? text,
    ButtonType? buttonType,
    $core.String? url,
  }) {
    final result = Button._();
    if (text != null) result.text = text;
    if (buttonType != null) result.buttonType = buttonType;
    if (url != null) result.url = url;
    return result;
  }

  Button._();

  factory Button.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Button()..mergeFromBuffer(data, registry);
  factory Button.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Button()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Button',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v2'),
      createEmptyInstance: Button.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'text')
    ..aE<ButtonType>(2, _omitFieldNames ? '' : 'buttonType',
        enumValues: ButtonType.values)
    ..aOS(3, _omitFieldNames ? '' : 'url')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Button clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Button copyWith(void Function(Button) updates) =>
      super.copyWith((message) => updates(message as Button)) as Button;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Button() / Button.new instead')
  static Button create() => Button._();
  static $pb.GeneratedMessage $_createMessage() => Button._();
  @$core.override
  Button createEmptyInstance() => Button._();
  @$core.pragma('dart2js:noInline')
  static Button getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Button>(Button.$_createMessage);
  static Button? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get text => $_getSZ(0);
  @$pb.TagNumber(1)
  set text($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasText() => $_has(0);
  @$pb.TagNumber(1)
  void clearText() => $_clearField(1);

  @$pb.TagNumber(2)
  ButtonType get buttonType => $_getN(1);
  @$pb.TagNumber(2)
  set buttonType(ButtonType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasButtonType() => $_has(1);
  @$pb.TagNumber(2)
  void clearButtonType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get url => $_getSZ(2);
  @$pb.TagNumber(3)
  set url($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUrl() => $_has(2);
  @$pb.TagNumber(3)
  void clearUrl() => $_clearField(3);
}

/// TextMessage holds the payload of a plain-text conversation turn.
class TextMessage extends $pb.GeneratedMessage {
  factory TextMessage({
    $0.Timestamp? timestamp,
    $core.String? text,
    MessageStatus? status,
    MessageRole? role,
  }) {
    final result = TextMessage._();
    if (timestamp != null) result.timestamp = timestamp;
    if (text != null) result.text = text;
    if (status != null) result.status = status;
    if (role != null) result.role = role;
    return result;
  }

  TextMessage._();

  factory TextMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TextMessage()..mergeFromBuffer(data, registry);
  factory TextMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TextMessage()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TextMessage',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v2'),
      createEmptyInstance: TextMessage.$_createMessage)
    ..aOM<$0.Timestamp>(1, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.$_createMessage)
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
  @$core.Deprecated('Use TextMessage() / TextMessage.new instead')
  static TextMessage create() => TextMessage._();
  static $pb.GeneratedMessage $_createMessage() => TextMessage._();
  @$core.override
  TextMessage createEmptyInstance() => TextMessage._();
  @$core.pragma('dart2js:noInline')
  static TextMessage getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TextMessage>(
          TextMessage.$_createMessage);
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
/// content.text serves as the body. header and footer are optional structural
/// fields rendered above and below the body, typically alongside buttons.
class TextMessageRequest extends $pb.GeneratedMessage {
  factory TextMessageRequest({
    TextMessage? content,
    $0.Timestamp? timestamp,
    $core.Iterable<Button>? buttons,
    $core.String? header,
    $core.String? footer,
  }) {
    final result = TextMessageRequest._();
    if (content != null) result.content = content;
    if (timestamp != null) result.timestamp = timestamp;
    if (buttons != null) result.buttons.addAll(buttons);
    if (header != null) result.header = header;
    if (footer != null) result.footer = footer;
    return result;
  }

  TextMessageRequest._();

  factory TextMessageRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TextMessageRequest()..mergeFromBuffer(data, registry);
  factory TextMessageRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TextMessageRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TextMessageRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v2'),
      createEmptyInstance: TextMessageRequest.$_createMessage)
    ..aOM<TextMessage>(1, _omitFieldNames ? '' : 'content',
        subBuilder: TextMessage.$_createMessage)
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.$_createMessage)
    ..pPM<Button>(3, _omitFieldNames ? '' : 'buttons',
        subBuilder: Button.$_createMessage)
    ..aOS(4, _omitFieldNames ? '' : 'header')
    ..aOS(5, _omitFieldNames ? '' : 'footer')
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
  @$core.Deprecated('Use TextMessageRequest() / TextMessageRequest.new instead')
  static TextMessageRequest create() => TextMessageRequest._();
  static $pb.GeneratedMessage $_createMessage() => TextMessageRequest._();
  @$core.override
  TextMessageRequest createEmptyInstance() => TextMessageRequest._();
  @$core.pragma('dart2js:noInline')
  static TextMessageRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TextMessageRequest>(
          TextMessageRequest.$_createMessage);
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

  @$pb.TagNumber(3)
  $pb.PbList<Button> get buttons => $_getList(2);

  @$pb.TagNumber(4)
  $core.String get header => $_getSZ(3);
  @$pb.TagNumber(4)
  set header($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHeader() => $_has(3);
  @$pb.TagNumber(4)
  void clearHeader() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get footer => $_getSZ(4);
  @$pb.TagNumber(5)
  set footer($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFooter() => $_has(4);
  @$pb.TagNumber(5)
  void clearFooter() => $_clearField(5);
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
    final result = VoiceMessage._();
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
      VoiceMessage()..mergeFromBuffer(data, registry);
  factory VoiceMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      VoiceMessage()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'VoiceMessage',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v2'),
      createEmptyInstance: VoiceMessage.$_createMessage)
    ..aOM<$0.Timestamp>(1, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.$_createMessage)
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
  @$core.Deprecated('Use VoiceMessage() / VoiceMessage.new instead')
  static VoiceMessage create() => VoiceMessage._();
  static $pb.GeneratedMessage $_createMessage() => VoiceMessage._();
  @$core.override
  VoiceMessage createEmptyInstance() => VoiceMessage._();
  @$core.pragma('dart2js:noInline')
  static VoiceMessage getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VoiceMessage>(
          VoiceMessage.$_createMessage);
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
    $core.Iterable<Button>? buttons,
    $core.String? header,
    $core.String? footer,
  }) {
    final result = VoiceNoteMessageRequest._();
    if (content != null) result.content = content;
    if (timestamp != null) result.timestamp = timestamp;
    if (buttons != null) result.buttons.addAll(buttons);
    if (header != null) result.header = header;
    if (footer != null) result.footer = footer;
    return result;
  }

  VoiceNoteMessageRequest._();

  factory VoiceNoteMessageRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      VoiceNoteMessageRequest()..mergeFromBuffer(data, registry);
  factory VoiceNoteMessageRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      VoiceNoteMessageRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'VoiceNoteMessageRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v2'),
      createEmptyInstance: VoiceNoteMessageRequest.$_createMessage)
    ..aOM<VoiceMessage>(1, _omitFieldNames ? '' : 'content',
        subBuilder: VoiceMessage.$_createMessage)
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.$_createMessage)
    ..pPM<Button>(3, _omitFieldNames ? '' : 'buttons',
        subBuilder: Button.$_createMessage)
    ..aOS(4, _omitFieldNames ? '' : 'header')
    ..aOS(5, _omitFieldNames ? '' : 'footer')
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
  @$core.Deprecated(
      'Use VoiceNoteMessageRequest() / VoiceNoteMessageRequest.new instead')
  static VoiceNoteMessageRequest create() => VoiceNoteMessageRequest._();
  static $pb.GeneratedMessage $_createMessage() => VoiceNoteMessageRequest._();
  @$core.override
  VoiceNoteMessageRequest createEmptyInstance() => VoiceNoteMessageRequest._();
  @$core.pragma('dart2js:noInline')
  static VoiceNoteMessageRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<VoiceNoteMessageRequest>(
          VoiceNoteMessageRequest.$_createMessage);
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
  $pb.PbList<Button> get buttons => $_getList(2);

  @$pb.TagNumber(4)
  $core.String get header => $_getSZ(3);
  @$pb.TagNumber(4)
  set header($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHeader() => $_has(3);
  @$pb.TagNumber(4)
  void clearHeader() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get footer => $_getSZ(4);
  @$pb.TagNumber(5)
  set footer($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFooter() => $_has(4);
  @$pb.TagNumber(5)
  void clearFooter() => $_clearField(5);
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
    final result = ImageMessage._();
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
      ImageMessage()..mergeFromBuffer(data, registry);
  factory ImageMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImageMessage()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ImageMessage',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v2'),
      createEmptyInstance: ImageMessage.$_createMessage)
    ..aOM<$0.Timestamp>(1, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.$_createMessage)
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
  @$core.Deprecated('Use ImageMessage() / ImageMessage.new instead')
  static ImageMessage create() => ImageMessage._();
  static $pb.GeneratedMessage $_createMessage() => ImageMessage._();
  @$core.override
  ImageMessage createEmptyInstance() => ImageMessage._();
  @$core.pragma('dart2js:noInline')
  static ImageMessage getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ImageMessage>(
          ImageMessage.$_createMessage);
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
    $core.Iterable<Button>? buttons,
    $core.String? header,
    $core.String? footer,
  }) {
    final result = ImageMessageRequest._();
    if (content != null) result.content = content;
    if (timestamp != null) result.timestamp = timestamp;
    if (buttons != null) result.buttons.addAll(buttons);
    if (header != null) result.header = header;
    if (footer != null) result.footer = footer;
    return result;
  }

  ImageMessageRequest._();

  factory ImageMessageRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImageMessageRequest()..mergeFromBuffer(data, registry);
  factory ImageMessageRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImageMessageRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ImageMessageRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v2'),
      createEmptyInstance: ImageMessageRequest.$_createMessage)
    ..aOM<ImageMessage>(1, _omitFieldNames ? '' : 'content',
        subBuilder: ImageMessage.$_createMessage)
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.$_createMessage)
    ..pPM<Button>(3, _omitFieldNames ? '' : 'buttons',
        subBuilder: Button.$_createMessage)
    ..aOS(4, _omitFieldNames ? '' : 'header')
    ..aOS(5, _omitFieldNames ? '' : 'footer')
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
  @$core
      .Deprecated('Use ImageMessageRequest() / ImageMessageRequest.new instead')
  static ImageMessageRequest create() => ImageMessageRequest._();
  static $pb.GeneratedMessage $_createMessage() => ImageMessageRequest._();
  @$core.override
  ImageMessageRequest createEmptyInstance() => ImageMessageRequest._();
  @$core.pragma('dart2js:noInline')
  static ImageMessageRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ImageMessageRequest>(
          ImageMessageRequest.$_createMessage);
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
  $pb.PbList<Button> get buttons => $_getList(2);

  @$pb.TagNumber(4)
  $core.String get header => $_getSZ(3);
  @$pb.TagNumber(4)
  set header($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHeader() => $_has(3);
  @$pb.TagNumber(4)
  void clearHeader() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get footer => $_getSZ(4);
  @$pb.TagNumber(5)
  set footer($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFooter() => $_has(4);
  @$pb.TagNumber(5)
  void clearFooter() => $_clearField(5);
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
    final result = AttachmentMessage._();
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
      AttachmentMessage()..mergeFromBuffer(data, registry);
  factory AttachmentMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AttachmentMessage()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AttachmentMessage',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v2'),
      createEmptyInstance: AttachmentMessage.$_createMessage)
    ..aOM<$0.Timestamp>(1, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.$_createMessage)
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
  @$core.Deprecated('Use AttachmentMessage() / AttachmentMessage.new instead')
  static AttachmentMessage create() => AttachmentMessage._();
  static $pb.GeneratedMessage $_createMessage() => AttachmentMessage._();
  @$core.override
  AttachmentMessage createEmptyInstance() => AttachmentMessage._();
  @$core.pragma('dart2js:noInline')
  static AttachmentMessage getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AttachmentMessage>(
          AttachmentMessage.$_createMessage);
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
    $core.Iterable<Button>? buttons,
    $core.String? header,
    $core.String? footer,
  }) {
    final result = AttachmentMessageRequest._();
    if (content != null) result.content = content;
    if (timestamp != null) result.timestamp = timestamp;
    if (buttons != null) result.buttons.addAll(buttons);
    if (header != null) result.header = header;
    if (footer != null) result.footer = footer;
    return result;
  }

  AttachmentMessageRequest._();

  factory AttachmentMessageRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AttachmentMessageRequest()..mergeFromBuffer(data, registry);
  factory AttachmentMessageRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AttachmentMessageRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AttachmentMessageRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v2'),
      createEmptyInstance: AttachmentMessageRequest.$_createMessage)
    ..aOM<AttachmentMessage>(1, _omitFieldNames ? '' : 'content',
        subBuilder: AttachmentMessage.$_createMessage)
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.$_createMessage)
    ..pPM<Button>(3, _omitFieldNames ? '' : 'buttons',
        subBuilder: Button.$_createMessage)
    ..aOS(4, _omitFieldNames ? '' : 'header')
    ..aOS(5, _omitFieldNames ? '' : 'footer')
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
  @$core.Deprecated(
      'Use AttachmentMessageRequest() / AttachmentMessageRequest.new instead')
  static AttachmentMessageRequest create() => AttachmentMessageRequest._();
  static $pb.GeneratedMessage $_createMessage() => AttachmentMessageRequest._();
  @$core.override
  AttachmentMessageRequest createEmptyInstance() =>
      AttachmentMessageRequest._();
  @$core.pragma('dart2js:noInline')
  static AttachmentMessageRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AttachmentMessageRequest>(
          AttachmentMessageRequest.$_createMessage);
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
  $pb.PbList<Button> get buttons => $_getList(2);

  @$pb.TagNumber(4)
  $core.String get header => $_getSZ(3);
  @$pb.TagNumber(4)
  set header($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHeader() => $_has(3);
  @$pb.TagNumber(4)
  void clearHeader() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get footer => $_getSZ(4);
  @$pb.TagNumber(5)
  set footer($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFooter() => $_has(4);
  @$pb.TagNumber(5)
  void clearFooter() => $_clearField(5);
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
    final result = VideoMessage._();
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
      VideoMessage()..mergeFromBuffer(data, registry);
  factory VideoMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      VideoMessage()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'VideoMessage',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v2'),
      createEmptyInstance: VideoMessage.$_createMessage)
    ..aOM<$0.Timestamp>(1, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.$_createMessage)
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
  @$core.Deprecated('Use VideoMessage() / VideoMessage.new instead')
  static VideoMessage create() => VideoMessage._();
  static $pb.GeneratedMessage $_createMessage() => VideoMessage._();
  @$core.override
  VideoMessage createEmptyInstance() => VideoMessage._();
  @$core.pragma('dart2js:noInline')
  static VideoMessage getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VideoMessage>(
          VideoMessage.$_createMessage);
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
    $core.Iterable<Button>? buttons,
    $core.String? header,
    $core.String? footer,
  }) {
    final result = VideoMessageRequest._();
    if (content != null) result.content = content;
    if (timestamp != null) result.timestamp = timestamp;
    if (buttons != null) result.buttons.addAll(buttons);
    if (header != null) result.header = header;
    if (footer != null) result.footer = footer;
    return result;
  }

  VideoMessageRequest._();

  factory VideoMessageRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      VideoMessageRequest()..mergeFromBuffer(data, registry);
  factory VideoMessageRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      VideoMessageRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'VideoMessageRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v2'),
      createEmptyInstance: VideoMessageRequest.$_createMessage)
    ..aOM<VideoMessage>(1, _omitFieldNames ? '' : 'content',
        subBuilder: VideoMessage.$_createMessage)
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.$_createMessage)
    ..pPM<Button>(3, _omitFieldNames ? '' : 'buttons',
        subBuilder: Button.$_createMessage)
    ..aOS(4, _omitFieldNames ? '' : 'header')
    ..aOS(5, _omitFieldNames ? '' : 'footer')
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
  @$core
      .Deprecated('Use VideoMessageRequest() / VideoMessageRequest.new instead')
  static VideoMessageRequest create() => VideoMessageRequest._();
  static $pb.GeneratedMessage $_createMessage() => VideoMessageRequest._();
  @$core.override
  VideoMessageRequest createEmptyInstance() => VideoMessageRequest._();
  @$core.pragma('dart2js:noInline')
  static VideoMessageRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<VideoMessageRequest>(
          VideoMessageRequest.$_createMessage);
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
  $pb.PbList<Button> get buttons => $_getList(2);

  @$pb.TagNumber(4)
  $core.String get header => $_getSZ(3);
  @$pb.TagNumber(4)
  set header($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHeader() => $_has(3);
  @$pb.TagNumber(4)
  void clearHeader() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get footer => $_getSZ(4);
  @$pb.TagNumber(5)
  set footer($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFooter() => $_has(4);
  @$pb.TagNumber(5)
  void clearFooter() => $_clearField(5);
}

/// MessageReceiptRequest notifies the other party of a message status change.
class MessageReceiptRequest extends $pb.GeneratedMessage {
  factory MessageReceiptRequest({
    MessageStatus? status,
    $core.String? messageId,
    $0.Timestamp? timestamp,
  }) {
    final result = MessageReceiptRequest._();
    if (status != null) result.status = status;
    if (messageId != null) result.messageId = messageId;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  MessageReceiptRequest._();

  factory MessageReceiptRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MessageReceiptRequest()..mergeFromBuffer(data, registry);
  factory MessageReceiptRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MessageReceiptRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MessageReceiptRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v2'),
      createEmptyInstance: MessageReceiptRequest.$_createMessage)
    ..aE<MessageStatus>(1, _omitFieldNames ? '' : 'status',
        enumValues: MessageStatus.values)
    ..aOS(2, _omitFieldNames ? '' : 'messageId')
    ..aOM<$0.Timestamp>(3, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.$_createMessage)
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
  @$core.Deprecated(
      'Use MessageReceiptRequest() / MessageReceiptRequest.new instead')
  static MessageReceiptRequest create() => MessageReceiptRequest._();
  static $pb.GeneratedMessage $_createMessage() => MessageReceiptRequest._();
  @$core.override
  MessageReceiptRequest createEmptyInstance() => MessageReceiptRequest._();
  @$core.pragma('dart2js:noInline')
  static MessageReceiptRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MessageReceiptRequest>(
          MessageReceiptRequest.$_createMessage);
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
}

/// AddToCartRequest asks the channel to add a SKU to the active cart.
class AddToCartRequest extends $pb.GeneratedMessage {
  factory AddToCartRequest({
    $core.String? sku,
    $0.Timestamp? timestamp,
    $core.double? quantity,
    UnitType? unitType,
  }) {
    final result = AddToCartRequest._();
    if (sku != null) result.sku = sku;
    if (timestamp != null) result.timestamp = timestamp;
    if (quantity != null) result.quantity = quantity;
    if (unitType != null) result.unitType = unitType;
    return result;
  }

  AddToCartRequest._();

  factory AddToCartRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AddToCartRequest()..mergeFromBuffer(data, registry);
  factory AddToCartRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AddToCartRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddToCartRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v2'),
      createEmptyInstance: AddToCartRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'sku')
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.$_createMessage)
    ..aD(3, _omitFieldNames ? '' : 'quantity')
    ..aE<UnitType>(4, _omitFieldNames ? '' : 'unitType',
        enumValues: UnitType.values)
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
  @$core.Deprecated('Use AddToCartRequest() / AddToCartRequest.new instead')
  static AddToCartRequest create() => AddToCartRequest._();
  static $pb.GeneratedMessage $_createMessage() => AddToCartRequest._();
  @$core.override
  AddToCartRequest createEmptyInstance() => AddToCartRequest._();
  @$core.pragma('dart2js:noInline')
  static AddToCartRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AddToCartRequest>(
          AddToCartRequest.$_createMessage);
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

  /// Whether the quantity refers to primary units or subunits.
  @$pb.TagNumber(4)
  UnitType get unitType => $_getN(3);
  @$pb.TagNumber(4)
  set unitType(UnitType value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasUnitType() => $_has(3);
  @$pb.TagNumber(4)
  void clearUnitType() => $_clearField(4);
}

/// AddToCartResponse acknowledges an AddToCartRequest.
class AddToCartResponse extends $pb.GeneratedMessage {
  factory AddToCartResponse({
    ResponseStatus? status,
    $0.Timestamp? timestamp,
  }) {
    final result = AddToCartResponse._();
    if (status != null) result.status = status;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  AddToCartResponse._();

  factory AddToCartResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AddToCartResponse()..mergeFromBuffer(data, registry);
  factory AddToCartResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AddToCartResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddToCartResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v2'),
      createEmptyInstance: AddToCartResponse.$_createMessage)
    ..aE<ResponseStatus>(1, _omitFieldNames ? '' : 'status',
        enumValues: ResponseStatus.values)
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.$_createMessage)
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
  @$core.Deprecated('Use AddToCartResponse() / AddToCartResponse.new instead')
  static AddToCartResponse create() => AddToCartResponse._();
  static $pb.GeneratedMessage $_createMessage() => AddToCartResponse._();
  @$core.override
  AddToCartResponse createEmptyInstance() => AddToCartResponse._();
  @$core.pragma('dart2js:noInline')
  static AddToCartResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AddToCartResponse>(
          AddToCartResponse.$_createMessage);
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
    UnitType? unitType,
  }) {
    final result = RemoveFromCartRequest._();
    if (sku != null) result.sku = sku;
    if (timestamp != null) result.timestamp = timestamp;
    if (quantity != null) result.quantity = quantity;
    if (unitType != null) result.unitType = unitType;
    return result;
  }

  RemoveFromCartRequest._();

  factory RemoveFromCartRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RemoveFromCartRequest()..mergeFromBuffer(data, registry);
  factory RemoveFromCartRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RemoveFromCartRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RemoveFromCartRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v2'),
      createEmptyInstance: RemoveFromCartRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'sku')
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.$_createMessage)
    ..aD(3, _omitFieldNames ? '' : 'quantity')
    ..aE<UnitType>(4, _omitFieldNames ? '' : 'unitType',
        enumValues: UnitType.values)
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
  @$core.Deprecated(
      'Use RemoveFromCartRequest() / RemoveFromCartRequest.new instead')
  static RemoveFromCartRequest create() => RemoveFromCartRequest._();
  static $pb.GeneratedMessage $_createMessage() => RemoveFromCartRequest._();
  @$core.override
  RemoveFromCartRequest createEmptyInstance() => RemoveFromCartRequest._();
  @$core.pragma('dart2js:noInline')
  static RemoveFromCartRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RemoveFromCartRequest>(
          RemoveFromCartRequest.$_createMessage);
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

  /// Whether the quantity refers to primary units or subunits.
  @$pb.TagNumber(4)
  UnitType get unitType => $_getN(3);
  @$pb.TagNumber(4)
  set unitType(UnitType value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasUnitType() => $_has(3);
  @$pb.TagNumber(4)
  void clearUnitType() => $_clearField(4);
}

/// RemoveFromCartResponse acknowledges a RemoveFromCartRequest.
class RemoveFromCartResponse extends $pb.GeneratedMessage {
  factory RemoveFromCartResponse({
    ResponseStatus? status,
    $0.Timestamp? timestamp,
  }) {
    final result = RemoveFromCartResponse._();
    if (status != null) result.status = status;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  RemoveFromCartResponse._();

  factory RemoveFromCartResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RemoveFromCartResponse()..mergeFromBuffer(data, registry);
  factory RemoveFromCartResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RemoveFromCartResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RemoveFromCartResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v2'),
      createEmptyInstance: RemoveFromCartResponse.$_createMessage)
    ..aE<ResponseStatus>(1, _omitFieldNames ? '' : 'status',
        enumValues: ResponseStatus.values)
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.$_createMessage)
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
  @$core.Deprecated(
      'Use RemoveFromCartResponse() / RemoveFromCartResponse.new instead')
  static RemoveFromCartResponse create() => RemoveFromCartResponse._();
  static $pb.GeneratedMessage $_createMessage() => RemoveFromCartResponse._();
  @$core.override
  RemoveFromCartResponse createEmptyInstance() => RemoveFromCartResponse._();
  @$core.pragma('dart2js:noInline')
  static RemoveFromCartResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RemoveFromCartResponse>(
          RemoveFromCartResponse.$_createMessage);
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
    final result = ClearCartRequest._();
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  ClearCartRequest._();

  factory ClearCartRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClearCartRequest()..mergeFromBuffer(data, registry);
  factory ClearCartRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClearCartRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClearCartRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v2'),
      createEmptyInstance: ClearCartRequest.$_createMessage)
    ..aOM<$0.Timestamp>(1, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.$_createMessage)
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
  @$core.Deprecated('Use ClearCartRequest() / ClearCartRequest.new instead')
  static ClearCartRequest create() => ClearCartRequest._();
  static $pb.GeneratedMessage $_createMessage() => ClearCartRequest._();
  @$core.override
  ClearCartRequest createEmptyInstance() => ClearCartRequest._();
  @$core.pragma('dart2js:noInline')
  static ClearCartRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClearCartRequest>(
          ClearCartRequest.$_createMessage);
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
    final result = ClearCartResponse._();
    if (status != null) result.status = status;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  ClearCartResponse._();

  factory ClearCartResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClearCartResponse()..mergeFromBuffer(data, registry);
  factory ClearCartResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClearCartResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClearCartResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v2'),
      createEmptyInstance: ClearCartResponse.$_createMessage)
    ..aE<ResponseStatus>(1, _omitFieldNames ? '' : 'status',
        enumValues: ResponseStatus.values)
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.$_createMessage)
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
  @$core.Deprecated('Use ClearCartResponse() / ClearCartResponse.new instead')
  static ClearCartResponse create() => ClearCartResponse._();
  static $pb.GeneratedMessage $_createMessage() => ClearCartResponse._();
  @$core.override
  ClearCartResponse createEmptyInstance() => ClearCartResponse._();
  @$core.pragma('dart2js:noInline')
  static ClearCartResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClearCartResponse>(
          ClearCartResponse.$_createMessage);
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

/// UpdateCartProductRequest sets the absolute quantities for a SKU in the
/// active cart, replacing whatever was there before. It is intended to
/// supersede AddToCartRequest / RemoveFromCartRequest so the channel does
/// not need to reconcile incremental deltas.
///
/// Semantics:
///   - units = 0 and subunits absent (or 0) removes the SKU from the cart.
///   - subunits is omitted for products that do not expose a subunit dimension.
class UpdateCartProductRequest extends $pb.GeneratedMessage {
  factory UpdateCartProductRequest({
    $core.String? sku,
    $0.Timestamp? timestamp,
    $core.double? units,
    $core.double? subunits,
  }) {
    final result = UpdateCartProductRequest._();
    if (sku != null) result.sku = sku;
    if (timestamp != null) result.timestamp = timestamp;
    if (units != null) result.units = units;
    if (subunits != null) result.subunits = subunits;
    return result;
  }

  UpdateCartProductRequest._();

  factory UpdateCartProductRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateCartProductRequest()..mergeFromBuffer(data, registry);
  factory UpdateCartProductRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateCartProductRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateCartProductRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v2'),
      createEmptyInstance: UpdateCartProductRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'sku')
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.$_createMessage)
    ..aD(3, _omitFieldNames ? '' : 'units')
    ..aD(4, _omitFieldNames ? '' : 'subunits')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateCartProductRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateCartProductRequest copyWith(
          void Function(UpdateCartProductRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateCartProductRequest))
          as UpdateCartProductRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use UpdateCartProductRequest() / UpdateCartProductRequest.new instead')
  static UpdateCartProductRequest create() => UpdateCartProductRequest._();
  static $pb.GeneratedMessage $_createMessage() => UpdateCartProductRequest._();
  @$core.override
  UpdateCartProductRequest createEmptyInstance() =>
      UpdateCartProductRequest._();
  @$core.pragma('dart2js:noInline')
  static UpdateCartProductRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateCartProductRequest>(
          UpdateCartProductRequest.$_createMessage);
  static UpdateCartProductRequest? _defaultInstance;

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

  /// Absolute number of primary units for this SKU after the update.
  @$pb.TagNumber(3)
  $core.double get units => $_getN(2);
  @$pb.TagNumber(3)
  set units($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUnits() => $_has(2);
  @$pb.TagNumber(3)
  void clearUnits() => $_clearField(3);

  /// Absolute number of subunits for this SKU after the update. Omit when
  /// the product has no subunit dimension.
  @$pb.TagNumber(4)
  $core.double get subunits => $_getN(3);
  @$pb.TagNumber(4)
  set subunits($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSubunits() => $_has(3);
  @$pb.TagNumber(4)
  void clearSubunits() => $_clearField(4);
}

/// UpdateCartProductResponse acknowledges an UpdateCartProductRequest.
class UpdateCartProductResponse extends $pb.GeneratedMessage {
  factory UpdateCartProductResponse({
    ResponseStatus? status,
    $0.Timestamp? timestamp,
  }) {
    final result = UpdateCartProductResponse._();
    if (status != null) result.status = status;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  UpdateCartProductResponse._();

  factory UpdateCartProductResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateCartProductResponse()..mergeFromBuffer(data, registry);
  factory UpdateCartProductResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateCartProductResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateCartProductResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v2'),
      createEmptyInstance: UpdateCartProductResponse.$_createMessage)
    ..aE<ResponseStatus>(1, _omitFieldNames ? '' : 'status',
        enumValues: ResponseStatus.values)
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateCartProductResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateCartProductResponse copyWith(
          void Function(UpdateCartProductResponse) updates) =>
      super.copyWith((message) => updates(message as UpdateCartProductResponse))
          as UpdateCartProductResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use UpdateCartProductResponse() / UpdateCartProductResponse.new instead')
  static UpdateCartProductResponse create() => UpdateCartProductResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      UpdateCartProductResponse._();
  @$core.override
  UpdateCartProductResponse createEmptyInstance() =>
      UpdateCartProductResponse._();
  @$core.pragma('dart2js:noInline')
  static UpdateCartProductResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateCartProductResponse>(
          UpdateCartProductResponse.$_createMessage);
  static UpdateCartProductResponse? _defaultInstance;

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

/// PageInfo carries cursor-based pagination metadata for a page of results.
/// All cursor and count fields are optional so a source may expose only the
/// subset it can compute (e.g. cursors without a known total). Cursors are
/// opaque string tokens: numeric channels stringify their offset, token-based
/// channels send the token verbatim, and the client passes them back unchanged.
class PageInfo extends $pb.GeneratedMessage {
  factory PageInfo({
    $core.int? total,
    $core.int? totalPages,
    $core.int? page,
    $core.String? cursor,
    $core.String? nextCursor,
    $core.String? prevCursor,
    $core.int? pageSize,
  }) {
    final result = PageInfo._();
    if (total != null) result.total = total;
    if (totalPages != null) result.totalPages = totalPages;
    if (page != null) result.page = page;
    if (cursor != null) result.cursor = cursor;
    if (nextCursor != null) result.nextCursor = nextCursor;
    if (prevCursor != null) result.prevCursor = prevCursor;
    if (pageSize != null) result.pageSize = pageSize;
    return result;
  }

  PageInfo._();

  factory PageInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PageInfo()..mergeFromBuffer(data, registry);
  factory PageInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PageInfo()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PageInfo',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v2'),
      createEmptyInstance: PageInfo.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'total')
    ..aI(2, _omitFieldNames ? '' : 'totalPages')
    ..aI(3, _omitFieldNames ? '' : 'page')
    ..aOS(4, _omitFieldNames ? '' : 'cursor')
    ..aOS(5, _omitFieldNames ? '' : 'nextCursor')
    ..aOS(6, _omitFieldNames ? '' : 'prevCursor')
    ..aI(7, _omitFieldNames ? '' : 'pageSize')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PageInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PageInfo copyWith(void Function(PageInfo) updates) =>
      super.copyWith((message) => updates(message as PageInfo)) as PageInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PageInfo() / PageInfo.new instead')
  static PageInfo create() => PageInfo._();
  static $pb.GeneratedMessage $_createMessage() => PageInfo._();
  @$core.override
  PageInfo createEmptyInstance() => PageInfo._();
  @$core.pragma('dart2js:noInline')
  static PageInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PageInfo>(PageInfo.$_createMessage);
  static PageInfo? _defaultInstance;

  /// Total number of items across all pages, when known.
  @$pb.TagNumber(1)
  $core.int get total => $_getIZ(0);
  @$pb.TagNumber(1)
  set total($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTotal() => $_has(0);
  @$pb.TagNumber(1)
  void clearTotal() => $_clearField(1);

  /// Total number of pages across the full result set, when known.
  @$pb.TagNumber(2)
  $core.int get totalPages => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalPages($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalPages() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalPages() => $_clearField(2);

  /// Current page index, when the source paginates by page number.
  @$pb.TagNumber(3)
  $core.int get page => $_getIZ(2);
  @$pb.TagNumber(3)
  set page($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPage() => $_has(2);
  @$pb.TagNumber(3)
  void clearPage() => $_clearField(3);

  /// Cursor that produced the current page.
  @$pb.TagNumber(4)
  $core.String get cursor => $_getSZ(3);
  @$pb.TagNumber(4)
  set cursor($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCursor() => $_has(3);
  @$pb.TagNumber(4)
  void clearCursor() => $_clearField(4);

  /// Cursor to pass in the next request to fetch the following page.
  /// Absent when the current page is the last one.
  @$pb.TagNumber(5)
  $core.String get nextCursor => $_getSZ(4);
  @$pb.TagNumber(5)
  set nextCursor($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasNextCursor() => $_has(4);
  @$pb.TagNumber(5)
  void clearNextCursor() => $_clearField(5);

  /// Cursor to pass to fetch the previous page. Absent on the first page.
  @$pb.TagNumber(6)
  $core.String get prevCursor => $_getSZ(5);
  @$pb.TagNumber(6)
  set prevCursor($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPrevCursor() => $_has(5);
  @$pb.TagNumber(6)
  void clearPrevCursor() => $_clearField(6);

  /// Number of items requested per page.
  @$pb.TagNumber(7)
  $core.int get pageSize => $_getIZ(6);
  @$pb.TagNumber(7)
  set pageSize($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasPageSize() => $_has(6);
  @$pb.TagNumber(7)
  void clearPageSize() => $_clearField(7);
}

/// GetCartRequest asks the channel to return the products in the active cart,
/// one page at a time. Omit cursor to fetch the first page.
class GetCartRequest extends $pb.GeneratedMessage {
  factory GetCartRequest({
    $0.Timestamp? timestamp,
    $core.String? cursor,
    $core.int? pageSize,
  }) {
    final result = GetCartRequest._();
    if (timestamp != null) result.timestamp = timestamp;
    if (cursor != null) result.cursor = cursor;
    if (pageSize != null) result.pageSize = pageSize;
    return result;
  }

  GetCartRequest._();

  factory GetCartRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetCartRequest()..mergeFromBuffer(data, registry);
  factory GetCartRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetCartRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetCartRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v2'),
      createEmptyInstance: GetCartRequest.$_createMessage)
    ..aOM<$0.Timestamp>(1, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.$_createMessage)
    ..aOS(2, _omitFieldNames ? '' : 'cursor')
    ..aI(3, _omitFieldNames ? '' : 'pageSize')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCartRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCartRequest copyWith(void Function(GetCartRequest) updates) =>
      super.copyWith((message) => updates(message as GetCartRequest))
          as GetCartRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetCartRequest() / GetCartRequest.new instead')
  static GetCartRequest create() => GetCartRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetCartRequest._();
  @$core.override
  GetCartRequest createEmptyInstance() => GetCartRequest._();
  @$core.pragma('dart2js:noInline')
  static GetCartRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetCartRequest>(
          GetCartRequest.$_createMessage);
  static GetCartRequest? _defaultInstance;

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

  /// Cursor identifying the page to fetch. Omit to fetch the first page.
  @$pb.TagNumber(2)
  $core.String get cursor => $_getSZ(1);
  @$pb.TagNumber(2)
  set cursor($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCursor() => $_has(1);
  @$pb.TagNumber(2)
  void clearCursor() => $_clearField(2);

  /// Maximum number of products to return in the page. When omitted the
  /// channel applies its own default page size.
  @$pb.TagNumber(3)
  $core.int get pageSize => $_getIZ(2);
  @$pb.TagNumber(3)
  set pageSize($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPageSize() => $_has(2);
  @$pb.TagNumber(3)
  void clearPageSize() => $_clearField(3);
}

/// GetCartResponse returns a single page of products from the active cart.
class GetCartResponse extends $pb.GeneratedMessage {
  factory GetCartResponse({
    ResponseStatus? status,
    $0.Timestamp? timestamp,
    $core.Iterable<Product>? products,
    PageInfo? pageInfo,
  }) {
    final result = GetCartResponse._();
    if (status != null) result.status = status;
    if (timestamp != null) result.timestamp = timestamp;
    if (products != null) result.products.addAll(products);
    if (pageInfo != null) result.pageInfo = pageInfo;
    return result;
  }

  GetCartResponse._();

  factory GetCartResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetCartResponse()..mergeFromBuffer(data, registry);
  factory GetCartResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetCartResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetCartResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v2'),
      createEmptyInstance: GetCartResponse.$_createMessage)
    ..aE<ResponseStatus>(1, _omitFieldNames ? '' : 'status',
        enumValues: ResponseStatus.values)
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.$_createMessage)
    ..pPM<Product>(3, _omitFieldNames ? '' : 'products',
        subBuilder: Product.$_createMessage)
    ..aOM<PageInfo>(4, _omitFieldNames ? '' : 'pageInfo',
        subBuilder: PageInfo.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCartResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCartResponse copyWith(void Function(GetCartResponse) updates) =>
      super.copyWith((message) => updates(message as GetCartResponse))
          as GetCartResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetCartResponse() / GetCartResponse.new instead')
  static GetCartResponse create() => GetCartResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetCartResponse._();
  @$core.override
  GetCartResponse createEmptyInstance() => GetCartResponse._();
  @$core.pragma('dart2js:noInline')
  static GetCartResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetCartResponse>(
          GetCartResponse.$_createMessage);
  static GetCartResponse? _defaultInstance;

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

  /// Products contained in this page of the cart.
  @$pb.TagNumber(3)
  $pb.PbList<Product> get products => $_getList(2);

  /// Cursor-based pagination metadata describing this page and how to fetch
  /// adjacent ones.
  @$pb.TagNumber(4)
  PageInfo get pageInfo => $_getN(3);
  @$pb.TagNumber(4)
  set pageInfo(PageInfo value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasPageInfo() => $_has(3);
  @$pb.TagNumber(4)
  void clearPageInfo() => $_clearField(4);
  @$pb.TagNumber(4)
  PageInfo ensurePageInfo() => $_ensure(3);
}

/// GuidanceCardRequest asks the channel to return the current guidance cards.
class GuidanceCardRequest extends $pb.GeneratedMessage {
  factory GuidanceCardRequest({
    $0.Timestamp? timestamp,
    $core.String? targetId,
    $core.String? context,
  }) {
    final result = GuidanceCardRequest._();
    if (timestamp != null) result.timestamp = timestamp;
    if (targetId != null) result.targetId = targetId;
    if (context != null) result.context = context;
    return result;
  }

  GuidanceCardRequest._();

  factory GuidanceCardRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GuidanceCardRequest()..mergeFromBuffer(data, registry);
  factory GuidanceCardRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GuidanceCardRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GuidanceCardRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v2'),
      createEmptyInstance: GuidanceCardRequest.$_createMessage)
    ..aOM<$0.Timestamp>(1, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.$_createMessage)
    ..aOS(2, _omitFieldNames ? '' : 'targetId')
    ..aOS(3, _omitFieldNames ? '' : 'context')
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
  @$core
      .Deprecated('Use GuidanceCardRequest() / GuidanceCardRequest.new instead')
  static GuidanceCardRequest create() => GuidanceCardRequest._();
  static $pb.GeneratedMessage $_createMessage() => GuidanceCardRequest._();
  @$core.override
  GuidanceCardRequest createEmptyInstance() => GuidanceCardRequest._();
  @$core.pragma('dart2js:noInline')
  static GuidanceCardRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GuidanceCardRequest>(
          GuidanceCardRequest.$_createMessage);
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

  /// Identifies the target entity for which guidance cards are requested.
  @$pb.TagNumber(2)
  $core.String get targetId => $_getSZ(1);
  @$pb.TagNumber(2)
  set targetId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTargetId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTargetId() => $_clearField(2);

  /// Additional context for the guidance card lookup.
  @$pb.TagNumber(3)
  $core.String get context => $_getSZ(2);
  @$pb.TagNumber(3)
  set context($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasContext() => $_has(2);
  @$pb.TagNumber(3)
  void clearContext() => $_clearField(3);
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
    final result = GuidanceCardResponse._();
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
      GuidanceCardResponse()..mergeFromBuffer(data, registry);
  factory GuidanceCardResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GuidanceCardResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GuidanceCardResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v2'),
      createEmptyInstance: GuidanceCardResponse.$_createMessage)
    ..aE<ResponseStatus>(1, _omitFieldNames ? '' : 'status',
        enumValues: ResponseStatus.values)
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.$_createMessage)
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
  @$core.Deprecated(
      'Use GuidanceCardResponse() / GuidanceCardResponse.new instead')
  static GuidanceCardResponse create() => GuidanceCardResponse._();
  static $pb.GeneratedMessage $_createMessage() => GuidanceCardResponse._();
  @$core.override
  GuidanceCardResponse createEmptyInstance() => GuidanceCardResponse._();
  @$core.pragma('dart2js:noInline')
  static GuidanceCardResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GuidanceCardResponse>(
          GuidanceCardResponse.$_createMessage);
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
    final result = AddPromotionRequest._();
    if (promotionId != null) result.promotionId = promotionId;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  AddPromotionRequest._();

  factory AddPromotionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AddPromotionRequest()..mergeFromBuffer(data, registry);
  factory AddPromotionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AddPromotionRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddPromotionRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v2'),
      createEmptyInstance: AddPromotionRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'promotionId')
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.$_createMessage)
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
  @$core
      .Deprecated('Use AddPromotionRequest() / AddPromotionRequest.new instead')
  static AddPromotionRequest create() => AddPromotionRequest._();
  static $pb.GeneratedMessage $_createMessage() => AddPromotionRequest._();
  @$core.override
  AddPromotionRequest createEmptyInstance() => AddPromotionRequest._();
  @$core.pragma('dart2js:noInline')
  static AddPromotionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddPromotionRequest>(
          AddPromotionRequest.$_createMessage);
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
    final result = AddPromotionResponse._();
    if (status != null) result.status = status;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  AddPromotionResponse._();

  factory AddPromotionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AddPromotionResponse()..mergeFromBuffer(data, registry);
  factory AddPromotionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AddPromotionResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddPromotionResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v2'),
      createEmptyInstance: AddPromotionResponse.$_createMessage)
    ..aE<ResponseStatus>(1, _omitFieldNames ? '' : 'status',
        enumValues: ResponseStatus.values)
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.$_createMessage)
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
  @$core.Deprecated(
      'Use AddPromotionResponse() / AddPromotionResponse.new instead')
  static AddPromotionResponse create() => AddPromotionResponse._();
  static $pb.GeneratedMessage $_createMessage() => AddPromotionResponse._();
  @$core.override
  AddPromotionResponse createEmptyInstance() => AddPromotionResponse._();
  @$core.pragma('dart2js:noInline')
  static AddPromotionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddPromotionResponse>(
          AddPromotionResponse.$_createMessage);
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
    final result = PromotionMessageRequest._();
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
      PromotionMessageRequest()..mergeFromBuffer(data, registry);
  factory PromotionMessageRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PromotionMessageRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PromotionMessageRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v2'),
      createEmptyInstance: PromotionMessageRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'promotionId')
    ..aOS(2, _omitFieldNames ? '' : 'title')
    ..aOS(3, _omitFieldNames ? '' : 'gain')
    ..aOS(4, _omitFieldNames ? '' : 'description')
    ..aOS(5, _omitFieldNames ? '' : 'imageUrl')
    ..aOS(6, _omitFieldNames ? '' : 'footer')
    ..aOM<$0.Timestamp>(7, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.$_createMessage)
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
  @$core.Deprecated(
      'Use PromotionMessageRequest() / PromotionMessageRequest.new instead')
  static PromotionMessageRequest create() => PromotionMessageRequest._();
  static $pb.GeneratedMessage $_createMessage() => PromotionMessageRequest._();
  @$core.override
  PromotionMessageRequest createEmptyInstance() => PromotionMessageRequest._();
  @$core.pragma('dart2js:noInline')
  static PromotionMessageRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PromotionMessageRequest>(
          PromotionMessageRequest.$_createMessage);
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
    final result = PromotionMessageResponse._();
    if (status != null) result.status = status;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  PromotionMessageResponse._();

  factory PromotionMessageResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PromotionMessageResponse()..mergeFromBuffer(data, registry);
  factory PromotionMessageResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PromotionMessageResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PromotionMessageResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v2'),
      createEmptyInstance: PromotionMessageResponse.$_createMessage)
    ..aE<ResponseStatus>(1, _omitFieldNames ? '' : 'status',
        enumValues: ResponseStatus.values)
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.$_createMessage)
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
  @$core.Deprecated(
      'Use PromotionMessageResponse() / PromotionMessageResponse.new instead')
  static PromotionMessageResponse create() => PromotionMessageResponse._();
  static $pb.GeneratedMessage $_createMessage() => PromotionMessageResponse._();
  @$core.override
  PromotionMessageResponse createEmptyInstance() =>
      PromotionMessageResponse._();
  @$core.pragma('dart2js:noInline')
  static PromotionMessageResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PromotionMessageResponse>(
          PromotionMessageResponse.$_createMessage);
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
    final result = Product._();
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
      Product()..mergeFromBuffer(data, registry);
  factory Product.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Product()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Product',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v2'),
      createEmptyInstance: Product.$_createMessage)
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
  @$core.Deprecated('Use Product() / Product.new instead')
  static Product create() => Product._();
  static $pb.GeneratedMessage $_createMessage() => Product._();
  @$core.override
  Product createEmptyInstance() => Product._();
  @$core.pragma('dart2js:noInline')
  static Product getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Product>(Product.$_createMessage);
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
    final result = ProductMessageRequest._();
    if (products != null) result.products.addAll(products);
    if (orientation != null) result.orientation = orientation;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  ProductMessageRequest._();

  factory ProductMessageRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProductMessageRequest()..mergeFromBuffer(data, registry);
  factory ProductMessageRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProductMessageRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProductMessageRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v2'),
      createEmptyInstance: ProductMessageRequest.$_createMessage)
    ..pPM<Product>(1, _omitFieldNames ? '' : 'products',
        subBuilder: Product.$_createMessage)
    ..aE<ProductMessageRequest_Orientation>(
        2, _omitFieldNames ? '' : 'orientation',
        enumValues: ProductMessageRequest_Orientation.values)
    ..aOM<$0.Timestamp>(3, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.$_createMessage)
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
  @$core.Deprecated(
      'Use ProductMessageRequest() / ProductMessageRequest.new instead')
  static ProductMessageRequest create() => ProductMessageRequest._();
  static $pb.GeneratedMessage $_createMessage() => ProductMessageRequest._();
  @$core.override
  ProductMessageRequest createEmptyInstance() => ProductMessageRequest._();
  @$core.pragma('dart2js:noInline')
  static ProductMessageRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ProductMessageRequest>(
          ProductMessageRequest.$_createMessage);
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
    final result = ProductMessageResponse._();
    if (status != null) result.status = status;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  ProductMessageResponse._();

  factory ProductMessageResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProductMessageResponse()..mergeFromBuffer(data, registry);
  factory ProductMessageResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProductMessageResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProductMessageResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v2'),
      createEmptyInstance: ProductMessageResponse.$_createMessage)
    ..aE<ResponseStatus>(1, _omitFieldNames ? '' : 'status',
        enumValues: ResponseStatus.values)
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.$_createMessage)
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
  @$core.Deprecated(
      'Use ProductMessageResponse() / ProductMessageResponse.new instead')
  static ProductMessageResponse create() => ProductMessageResponse._();
  static $pb.GeneratedMessage $_createMessage() => ProductMessageResponse._();
  @$core.override
  ProductMessageResponse createEmptyInstance() => ProductMessageResponse._();
  @$core.pragma('dart2js:noInline')
  static ProductMessageResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ProductMessageResponse>(
          ProductMessageResponse.$_createMessage);
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

/// ProductConfirmationMessageRequest confirms a product cart change in the
/// client UI, identifying the affected SKU and the resulting unit/subunit
/// quantities after the operation. Display-only fields (name, price, image)
/// are resolved by the client from its own product catalog cache.
class ProductConfirmationMessageRequest extends $pb.GeneratedMessage {
  factory ProductConfirmationMessageRequest({
    $core.String? sku,
    $0.Timestamp? timestamp,
    $core.double? units,
    $core.double? subunits,
    $core.String? header,
    $core.String? body,
    Button? button,
    $core.String? footer,
  }) {
    final result = ProductConfirmationMessageRequest._();
    if (sku != null) result.sku = sku;
    if (timestamp != null) result.timestamp = timestamp;
    if (units != null) result.units = units;
    if (subunits != null) result.subunits = subunits;
    if (header != null) result.header = header;
    if (body != null) result.body = body;
    if (button != null) result.button = button;
    if (footer != null) result.footer = footer;
    return result;
  }

  ProductConfirmationMessageRequest._();

  factory ProductConfirmationMessageRequest.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProductConfirmationMessageRequest()..mergeFromBuffer(data, registry);
  factory ProductConfirmationMessageRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProductConfirmationMessageRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProductConfirmationMessageRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v2'),
      createEmptyInstance: ProductConfirmationMessageRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'sku')
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.$_createMessage)
    ..aD(3, _omitFieldNames ? '' : 'units')
    ..aD(4, _omitFieldNames ? '' : 'subunits')
    ..aOS(5, _omitFieldNames ? '' : 'header')
    ..aOS(6, _omitFieldNames ? '' : 'body')
    ..aOM<Button>(7, _omitFieldNames ? '' : 'button',
        subBuilder: Button.$_createMessage)
    ..aOS(8, _omitFieldNames ? '' : 'footer')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProductConfirmationMessageRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProductConfirmationMessageRequest copyWith(
          void Function(ProductConfirmationMessageRequest) updates) =>
      super.copyWith((message) =>
              updates(message as ProductConfirmationMessageRequest))
          as ProductConfirmationMessageRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ProductConfirmationMessageRequest() / ProductConfirmationMessageRequest.new instead')
  static ProductConfirmationMessageRequest create() =>
      ProductConfirmationMessageRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      ProductConfirmationMessageRequest._();
  @$core.override
  ProductConfirmationMessageRequest createEmptyInstance() =>
      ProductConfirmationMessageRequest._();
  @$core.pragma('dart2js:noInline')
  static ProductConfirmationMessageRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ProductConfirmationMessageRequest>(
          ProductConfirmationMessageRequest.$_createMessage);
  static ProductConfirmationMessageRequest? _defaultInstance;

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

  /// Absolute number of primary units for this SKU after the confirmed change.
  @$pb.TagNumber(3)
  $core.double get units => $_getN(2);
  @$pb.TagNumber(3)
  set units($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUnits() => $_has(2);
  @$pb.TagNumber(3)
  void clearUnits() => $_clearField(3);

  /// Absolute number of subunits for this SKU after the confirmed change.
  /// Omit when the product has no subunit dimension.
  @$pb.TagNumber(4)
  $core.double get subunits => $_getN(3);
  @$pb.TagNumber(4)
  set subunits($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSubunits() => $_has(3);
  @$pb.TagNumber(4)
  void clearSubunits() => $_clearField(4);

  /// Structural text rendered above the confirmation card body.
  @$pb.TagNumber(5)
  $core.String get header => $_getSZ(4);
  @$pb.TagNumber(5)
  set header($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasHeader() => $_has(4);
  @$pb.TagNumber(5)
  void clearHeader() => $_clearField(5);

  /// Body text rendered as the main content of the confirmation card.
  @$pb.TagNumber(6)
  $core.String get body => $_getSZ(5);
  @$pb.TagNumber(6)
  set body($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasBody() => $_has(5);
  @$pb.TagNumber(6)
  void clearBody() => $_clearField(6);

  /// Call-to-action button rendered alongside the confirmation card.
  @$pb.TagNumber(7)
  Button get button => $_getN(6);
  @$pb.TagNumber(7)
  set button(Button value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasButton() => $_has(6);
  @$pb.TagNumber(7)
  void clearButton() => $_clearField(7);
  @$pb.TagNumber(7)
  Button ensureButton() => $_ensure(6);

  /// Structural text rendered below the confirmation card body.
  @$pb.TagNumber(8)
  $core.String get footer => $_getSZ(7);
  @$pb.TagNumber(8)
  set footer($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasFooter() => $_has(7);
  @$pb.TagNumber(8)
  void clearFooter() => $_clearField(8);
}

/// ProductConfirmationMessageResponse acknowledges a ProductConfirmationMessageRequest.
class ProductConfirmationMessageResponse extends $pb.GeneratedMessage {
  factory ProductConfirmationMessageResponse({
    ResponseStatus? status,
    $0.Timestamp? timestamp,
  }) {
    final result = ProductConfirmationMessageResponse._();
    if (status != null) result.status = status;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  ProductConfirmationMessageResponse._();

  factory ProductConfirmationMessageResponse.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProductConfirmationMessageResponse()..mergeFromBuffer(data, registry);
  factory ProductConfirmationMessageResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProductConfirmationMessageResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProductConfirmationMessageResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v2'),
      createEmptyInstance: ProductConfirmationMessageResponse.$_createMessage)
    ..aE<ResponseStatus>(1, _omitFieldNames ? '' : 'status',
        enumValues: ResponseStatus.values)
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProductConfirmationMessageResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProductConfirmationMessageResponse copyWith(
          void Function(ProductConfirmationMessageResponse) updates) =>
      super.copyWith((message) =>
              updates(message as ProductConfirmationMessageResponse))
          as ProductConfirmationMessageResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ProductConfirmationMessageResponse() / ProductConfirmationMessageResponse.new instead')
  static ProductConfirmationMessageResponse create() =>
      ProductConfirmationMessageResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      ProductConfirmationMessageResponse._();
  @$core.override
  ProductConfirmationMessageResponse createEmptyInstance() =>
      ProductConfirmationMessageResponse._();
  @$core.pragma('dart2js:noInline')
  static ProductConfirmationMessageResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ProductConfirmationMessageResponse>(
          ProductConfirmationMessageResponse.$_createMessage);
  static ProductConfirmationMessageResponse? _defaultInstance;

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
    final result = ChatStatusRequest._();
    if (status != null) result.status = status;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  ChatStatusRequest._();

  factory ChatStatusRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChatStatusRequest()..mergeFromBuffer(data, registry);
  factory ChatStatusRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChatStatusRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChatStatusRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v2'),
      createEmptyInstance: ChatStatusRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'status')
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.$_createMessage)
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
  @$core.Deprecated('Use ChatStatusRequest() / ChatStatusRequest.new instead')
  static ChatStatusRequest create() => ChatStatusRequest._();
  static $pb.GeneratedMessage $_createMessage() => ChatStatusRequest._();
  @$core.override
  ChatStatusRequest createEmptyInstance() => ChatStatusRequest._();
  @$core.pragma('dart2js:noInline')
  static ChatStatusRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChatStatusRequest>(
          ChatStatusRequest.$_createMessage);
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
    final result = ChatStatusResponse._();
    if (status != null) result.status = status;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  ChatStatusResponse._();

  factory ChatStatusResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChatStatusResponse()..mergeFromBuffer(data, registry);
  factory ChatStatusResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChatStatusResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChatStatusResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v2'),
      createEmptyInstance: ChatStatusResponse.$_createMessage)
    ..aE<ResponseStatus>(1, _omitFieldNames ? '' : 'status',
        enumValues: ResponseStatus.values)
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.$_createMessage)
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
  @$core.Deprecated('Use ChatStatusResponse() / ChatStatusResponse.new instead')
  static ChatStatusResponse create() => ChatStatusResponse._();
  static $pb.GeneratedMessage $_createMessage() => ChatStatusResponse._();
  @$core.override
  ChatStatusResponse createEmptyInstance() => ChatStatusResponse._();
  @$core.pragma('dart2js:noInline')
  static ChatStatusResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChatStatusResponse>(
          ChatStatusResponse.$_createMessage);
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

/// CustomCommandRequest triggers a client-side command identified by command_id.
class CustomCommandRequest extends $pb.GeneratedMessage {
  factory CustomCommandRequest({
    $core.String? commandId,
    $core.String? payload,
    $0.Timestamp? timestamp,
  }) {
    final result = CustomCommandRequest._();
    if (commandId != null) result.commandId = commandId;
    if (payload != null) result.payload = payload;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  CustomCommandRequest._();

  factory CustomCommandRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CustomCommandRequest()..mergeFromBuffer(data, registry);
  factory CustomCommandRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CustomCommandRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CustomCommandRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v2'),
      createEmptyInstance: CustomCommandRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'commandId')
    ..aOS(2, _omitFieldNames ? '' : 'payload')
    ..aOM<$0.Timestamp>(3, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CustomCommandRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CustomCommandRequest copyWith(void Function(CustomCommandRequest) updates) =>
      super.copyWith((message) => updates(message as CustomCommandRequest))
          as CustomCommandRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CustomCommandRequest() / CustomCommandRequest.new instead')
  static CustomCommandRequest create() => CustomCommandRequest._();
  static $pb.GeneratedMessage $_createMessage() => CustomCommandRequest._();
  @$core.override
  CustomCommandRequest createEmptyInstance() => CustomCommandRequest._();
  @$core.pragma('dart2js:noInline')
  static CustomCommandRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CustomCommandRequest>(
          CustomCommandRequest.$_createMessage);
  static CustomCommandRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get commandId => $_getSZ(0);
  @$pb.TagNumber(1)
  set commandId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCommandId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCommandId() => $_clearField(1);

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

/// CustomCommandResponse returns the result of a CustomCommandRequest.
class CustomCommandResponse extends $pb.GeneratedMessage {
  factory CustomCommandResponse({
    ResponseStatus? status,
    $core.String? payload,
    $0.Timestamp? timestamp,
  }) {
    final result = CustomCommandResponse._();
    if (status != null) result.status = status;
    if (payload != null) result.payload = payload;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  CustomCommandResponse._();

  factory CustomCommandResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CustomCommandResponse()..mergeFromBuffer(data, registry);
  factory CustomCommandResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CustomCommandResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CustomCommandResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v2'),
      createEmptyInstance: CustomCommandResponse.$_createMessage)
    ..aE<ResponseStatus>(1, _omitFieldNames ? '' : 'status',
        enumValues: ResponseStatus.values)
    ..aOS(2, _omitFieldNames ? '' : 'payload')
    ..aOM<$0.Timestamp>(3, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CustomCommandResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CustomCommandResponse copyWith(
          void Function(CustomCommandResponse) updates) =>
      super.copyWith((message) => updates(message as CustomCommandResponse))
          as CustomCommandResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CustomCommandResponse() / CustomCommandResponse.new instead')
  static CustomCommandResponse create() => CustomCommandResponse._();
  static $pb.GeneratedMessage $_createMessage() => CustomCommandResponse._();
  @$core.override
  CustomCommandResponse createEmptyInstance() => CustomCommandResponse._();
  @$core.pragma('dart2js:noInline')
  static CustomCommandResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CustomCommandResponse>(
          CustomCommandResponse.$_createMessage);
  static CustomCommandResponse? _defaultInstance;

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

/// AuthRequest is the body of POST /auth used to obtain an initial access token.
class AuthRequest extends $pb.GeneratedMessage {
  factory AuthRequest({
    $core.String? userType,
    $core.String? channelId,
    $core.String? organizationId,
    $fixnum.Int64? timestamp,
  }) {
    final result = AuthRequest._();
    if (userType != null) result.userType = userType;
    if (channelId != null) result.channelId = channelId;
    if (organizationId != null) result.organizationId = organizationId;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  AuthRequest._();

  factory AuthRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AuthRequest()..mergeFromBuffer(data, registry);
  factory AuthRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AuthRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AuthRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v2'),
      createEmptyInstance: AuthRequest.$_createMessage)
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
  @$core.Deprecated('Use AuthRequest() / AuthRequest.new instead')
  static AuthRequest create() => AuthRequest._();
  static $pb.GeneratedMessage $_createMessage() => AuthRequest._();
  @$core.override
  AuthRequest createEmptyInstance() => AuthRequest._();
  @$core.pragma('dart2js:noInline')
  static AuthRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AuthRequest>(
          AuthRequest.$_createMessage);
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
    final result = RefreshTokenRequest._();
    if (grantType != null) result.grantType = grantType;
    if (refreshToken != null) result.refreshToken = refreshToken;
    return result;
  }

  RefreshTokenRequest._();

  factory RefreshTokenRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RefreshTokenRequest()..mergeFromBuffer(data, registry);
  factory RefreshTokenRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RefreshTokenRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RefreshTokenRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v2'),
      createEmptyInstance: RefreshTokenRequest.$_createMessage)
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
  @$core
      .Deprecated('Use RefreshTokenRequest() / RefreshTokenRequest.new instead')
  static RefreshTokenRequest create() => RefreshTokenRequest._();
  static $pb.GeneratedMessage $_createMessage() => RefreshTokenRequest._();
  @$core.override
  RefreshTokenRequest createEmptyInstance() => RefreshTokenRequest._();
  @$core.pragma('dart2js:noInline')
  static RefreshTokenRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RefreshTokenRequest>(
          RefreshTokenRequest.$_createMessage);
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
    final result = AuthResponse._();
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
      AuthResponse()..mergeFromBuffer(data, registry);
  factory AuthResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AuthResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AuthResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v2'),
      createEmptyInstance: AuthResponse.$_createMessage)
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
  @$core.Deprecated('Use AuthResponse() / AuthResponse.new instead')
  static AuthResponse create() => AuthResponse._();
  static $pb.GeneratedMessage $_createMessage() => AuthResponse._();
  @$core.override
  AuthResponse createEmptyInstance() => AuthResponse._();
  @$core.pragma('dart2js:noInline')
  static AuthResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AuthResponse>(
          AuthResponse.$_createMessage);
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

/// ConnectionAck is the first frame the server sends after accepting the
/// WebSocket upgrade. Clients must wait for it before flushing any buffered
/// SdkMessage frames and may use connection_id to correlate server-side logs.
class ConnectionAck extends $pb.GeneratedMessage {
  factory ConnectionAck({
    ConnectionAckType? type,
    $core.String? connectionId,
    $0.Timestamp? timestamp,
  }) {
    final result = ConnectionAck._();
    if (type != null) result.type = type;
    if (connectionId != null) result.connectionId = connectionId;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  ConnectionAck._();

  factory ConnectionAck.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ConnectionAck()..mergeFromBuffer(data, registry);
  factory ConnectionAck.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ConnectionAck()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConnectionAck',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v2'),
      createEmptyInstance: ConnectionAck.$_createMessage)
    ..aE<ConnectionAckType>(1, _omitFieldNames ? '' : 'type',
        enumValues: ConnectionAckType.values)
    ..aOS(2, _omitFieldNames ? '' : 'connectionId')
    ..aOM<$0.Timestamp>(3, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConnectionAck clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConnectionAck copyWith(void Function(ConnectionAck) updates) =>
      super.copyWith((message) => updates(message as ConnectionAck))
          as ConnectionAck;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ConnectionAck() / ConnectionAck.new instead')
  static ConnectionAck create() => ConnectionAck._();
  static $pb.GeneratedMessage $_createMessage() => ConnectionAck._();
  @$core.override
  ConnectionAck createEmptyInstance() => ConnectionAck._();
  @$core.pragma('dart2js:noInline')
  static ConnectionAck getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConnectionAck>(
          ConnectionAck.$_createMessage);
  static ConnectionAck? _defaultInstance;

  /// Constant discriminator; always CONNECTION_ACK_TYPE_CONNECTION_ACK.
  @$pb.TagNumber(1)
  ConnectionAckType get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(ConnectionAckType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get connectionId => $_getSZ(1);
  @$pb.TagNumber(2)
  set connectionId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasConnectionId() => $_has(1);
  @$pb.TagNumber(2)
  void clearConnectionId() => $_clearField(2);

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

/// SdkMessageAck is sent by the server to acknowledge receipt of a client
/// SdkMessage frame. correlation_id matches the SdkMessage.correlation_id
/// of the acknowledged frame.
class SdkMessageAck extends $pb.GeneratedMessage {
  factory SdkMessageAck({
    SdkMessageAckType? type,
    $core.String? correlationId,
    $0.Timestamp? timestamp,
  }) {
    final result = SdkMessageAck._();
    if (type != null) result.type = type;
    if (correlationId != null) result.correlationId = correlationId;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  SdkMessageAck._();

  factory SdkMessageAck.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SdkMessageAck()..mergeFromBuffer(data, registry);
  factory SdkMessageAck.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SdkMessageAck()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SdkMessageAck',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v2'),
      createEmptyInstance: SdkMessageAck.$_createMessage)
    ..aE<SdkMessageAckType>(1, _omitFieldNames ? '' : 'type',
        enumValues: SdkMessageAckType.values)
    ..aOS(2, _omitFieldNames ? '' : 'correlationId')
    ..aOM<$0.Timestamp>(3, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SdkMessageAck clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SdkMessageAck copyWith(void Function(SdkMessageAck) updates) =>
      super.copyWith((message) => updates(message as SdkMessageAck))
          as SdkMessageAck;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SdkMessageAck() / SdkMessageAck.new instead')
  static SdkMessageAck create() => SdkMessageAck._();
  static $pb.GeneratedMessage $_createMessage() => SdkMessageAck._();
  @$core.override
  SdkMessageAck createEmptyInstance() => SdkMessageAck._();
  @$core.pragma('dart2js:noInline')
  static SdkMessageAck getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SdkMessageAck>(
          SdkMessageAck.$_createMessage);
  static SdkMessageAck? _defaultInstance;

  /// Constant discriminator; always SDK_MESSAGE_ACK_TYPE_MESSAGE_ACK.
  @$pb.TagNumber(1)
  SdkMessageAckType get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(SdkMessageAckType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get correlationId => $_getSZ(1);
  @$pb.TagNumber(2)
  set correlationId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCorrelationId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCorrelationId() => $_clearField(2);

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
    final result = PollMessageItem._();
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
      PollMessageItem()..mergeFromBuffer(data, registry);
  factory PollMessageItem.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PollMessageItem()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PollMessageItem',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'yalo.external_channel.in_app.sdk.v2'),
      createEmptyInstance: PollMessageItem.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOM<SdkMessage>(2, _omitFieldNames ? '' : 'message',
        subBuilder: SdkMessage.$_createMessage)
    ..aOM<$0.Timestamp>(3, _omitFieldNames ? '' : 'date',
        subBuilder: $0.Timestamp.$_createMessage)
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
  @$core.Deprecated('Use PollMessageItem() / PollMessageItem.new instead')
  static PollMessageItem create() => PollMessageItem._();
  static $pb.GeneratedMessage $_createMessage() => PollMessageItem._();
  @$core.override
  PollMessageItem createEmptyInstance() => PollMessageItem._();
  @$core.pragma('dart2js:noInline')
  static PollMessageItem getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PollMessageItem>(
          PollMessageItem.$_createMessage);
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
