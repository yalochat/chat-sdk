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

/// ResponseStatus indicates whether a channel operation succeeded or failed.
class ResponseStatus extends $pb.ProtobufEnum {
  static const ResponseStatus RESPONSE_STATUS_UNSPECIFIED =
      ResponseStatus._(0, _omitEnumNames ? '' : 'RESPONSE_STATUS_UNSPECIFIED');
  static const ResponseStatus RESPONSE_STATUS_SUCCESS =
      ResponseStatus._(1, _omitEnumNames ? '' : 'RESPONSE_STATUS_SUCCESS');
  static const ResponseStatus RESPONSE_STATUS_ERROR =
      ResponseStatus._(2, _omitEnumNames ? '' : 'RESPONSE_STATUS_ERROR');

  static const $core.List<ResponseStatus> values = <ResponseStatus>[
    RESPONSE_STATUS_UNSPECIFIED,
    RESPONSE_STATUS_SUCCESS,
    RESPONSE_STATUS_ERROR,
  ];

  static final $core.List<ResponseStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static ResponseStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ResponseStatus._(super.value, super.name);
}

/// MessageRole identifies the originator of a message in the conversation.
class MessageRole extends $pb.ProtobufEnum {
  static const MessageRole MESSAGE_ROLE_UNSPECIFIED =
      MessageRole._(0, _omitEnumNames ? '' : 'MESSAGE_ROLE_UNSPECIFIED');
  static const MessageRole MESSAGE_ROLE_USER =
      MessageRole._(1, _omitEnumNames ? '' : 'MESSAGE_ROLE_USER');
  static const MessageRole MESSAGE_ROLE_AGENT =
      MessageRole._(2, _omitEnumNames ? '' : 'MESSAGE_ROLE_AGENT');

  static const $core.List<MessageRole> values = <MessageRole>[
    MESSAGE_ROLE_UNSPECIFIED,
    MESSAGE_ROLE_USER,
    MESSAGE_ROLE_AGENT,
  ];

  static final $core.List<MessageRole?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static MessageRole? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const MessageRole._(super.value, super.name);
}

/// UnitType discriminates whether a cart quantity change refers to
/// primary units (e.g. boxes) or subunits (e.g. individual items).
class UnitType extends $pb.ProtobufEnum {
  static const UnitType UNIT_TYPE_UNSPECIFIED =
      UnitType._(0, _omitEnumNames ? '' : 'UNIT_TYPE_UNSPECIFIED');
  static const UnitType UNIT_TYPE_UNIT =
      UnitType._(1, _omitEnumNames ? '' : 'UNIT_TYPE_UNIT');
  static const UnitType UNIT_TYPE_SUBUNIT =
      UnitType._(2, _omitEnumNames ? '' : 'UNIT_TYPE_SUBUNIT');

  static const $core.List<UnitType> values = <UnitType>[
    UNIT_TYPE_UNSPECIFIED,
    UNIT_TYPE_UNIT,
    UNIT_TYPE_SUBUNIT,
  ];

  static final $core.List<UnitType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static UnitType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const UnitType._(super.value, super.name);
}

/// MessageStatus tracks the delivery lifecycle of a single message.
class MessageStatus extends $pb.ProtobufEnum {
  static const MessageStatus MESSAGE_STATUS_UNSPECIFIED =
      MessageStatus._(0, _omitEnumNames ? '' : 'MESSAGE_STATUS_UNSPECIFIED');
  static const MessageStatus MESSAGE_STATUS_DELIVERED =
      MessageStatus._(1, _omitEnumNames ? '' : 'MESSAGE_STATUS_DELIVERED');
  static const MessageStatus MESSAGE_STATUS_IN_PROGRESS =
      MessageStatus._(2, _omitEnumNames ? '' : 'MESSAGE_STATUS_IN_PROGRESS');
  static const MessageStatus MESSAGE_STATUS_READ =
      MessageStatus._(3, _omitEnumNames ? '' : 'MESSAGE_STATUS_READ');
  static const MessageStatus MESSAGE_STATUS_ERROR =
      MessageStatus._(4, _omitEnumNames ? '' : 'MESSAGE_STATUS_ERROR');
  static const MessageStatus MESSAGE_STATUS_SENT =
      MessageStatus._(5, _omitEnumNames ? '' : 'MESSAGE_STATUS_SENT');
  static const MessageStatus MESSAGE_STATUS_IN_DELIVERY =
      MessageStatus._(6, _omitEnumNames ? '' : 'MESSAGE_STATUS_IN_DELIVERY');

  static const $core.List<MessageStatus> values = <MessageStatus>[
    MESSAGE_STATUS_UNSPECIFIED,
    MESSAGE_STATUS_DELIVERED,
    MESSAGE_STATUS_IN_PROGRESS,
    MESSAGE_STATUS_READ,
    MESSAGE_STATUS_ERROR,
    MESSAGE_STATUS_SENT,
    MESSAGE_STATUS_IN_DELIVERY,
  ];

  static final $core.List<MessageStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 6);
  static MessageStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const MessageStatus._(super.value, super.name);
}

/// ButtonType discriminates how a button should behave when tapped.
class ButtonType extends $pb.ProtobufEnum {
  static const ButtonType BUTTON_TYPE_REPLY =
      ButtonType._(0, _omitEnumNames ? '' : 'BUTTON_TYPE_REPLY');
  static const ButtonType BUTTON_TYPE_POSTBACK =
      ButtonType._(1, _omitEnumNames ? '' : 'BUTTON_TYPE_POSTBACK');
  static const ButtonType BUTTON_TYPE_LINK =
      ButtonType._(2, _omitEnumNames ? '' : 'BUTTON_TYPE_LINK');

  static const $core.List<ButtonType> values = <ButtonType>[
    BUTTON_TYPE_REPLY,
    BUTTON_TYPE_POSTBACK,
    BUTTON_TYPE_LINK,
  ];

  static final $core.List<ButtonType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static ButtonType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ButtonType._(super.value, super.name);
}

/// SdkCommand enumerates the commands the SDK is able to execute on the client.
class SdkCommand extends $pb.ProtobufEnum {
  static const SdkCommand SDK_COMMAND_UNSPECIFIED =
      SdkCommand._(0, _omitEnumNames ? '' : 'SDK_COMMAND_UNSPECIFIED');
  static const SdkCommand SDK_COMMAND_ADD_TO_CART =
      SdkCommand._(1, _omitEnumNames ? '' : 'SDK_COMMAND_ADD_TO_CART');
  static const SdkCommand SDK_COMMAND_REMOVE_FROM_CART =
      SdkCommand._(2, _omitEnumNames ? '' : 'SDK_COMMAND_REMOVE_FROM_CART');
  static const SdkCommand SDK_COMMAND_CLEAR_CART =
      SdkCommand._(3, _omitEnumNames ? '' : 'SDK_COMMAND_CLEAR_CART');
  static const SdkCommand SDK_COMMAND_GUIDANCE_CARD =
      SdkCommand._(4, _omitEnumNames ? '' : 'SDK_COMMAND_GUIDANCE_CARD');
  static const SdkCommand SDK_COMMAND_ADD_PROMOTION =
      SdkCommand._(5, _omitEnumNames ? '' : 'SDK_COMMAND_ADD_PROMOTION');

  static const $core.List<SdkCommand> values = <SdkCommand>[
    SDK_COMMAND_UNSPECIFIED,
    SDK_COMMAND_ADD_TO_CART,
    SDK_COMMAND_REMOVE_FROM_CART,
    SDK_COMMAND_CLEAR_CART,
    SDK_COMMAND_GUIDANCE_CARD,
    SDK_COMMAND_ADD_PROMOTION,
  ];

  static final $core.List<SdkCommand?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static SdkCommand? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SdkCommand._(super.value, super.name);
}

/// Orientation controls how the product list is rendered in the client UI.
class ProductMessageRequest_Orientation extends $pb.ProtobufEnum {
  static const ProductMessageRequest_Orientation ORIENTATION_UNSPECIFIED =
      ProductMessageRequest_Orientation._(
          0, _omitEnumNames ? '' : 'ORIENTATION_UNSPECIFIED');
  static const ProductMessageRequest_Orientation ORIENTATION_VERTICAL =
      ProductMessageRequest_Orientation._(
          1, _omitEnumNames ? '' : 'ORIENTATION_VERTICAL');
  static const ProductMessageRequest_Orientation ORIENTATION_HORIZONTAL =
      ProductMessageRequest_Orientation._(
          2, _omitEnumNames ? '' : 'ORIENTATION_HORIZONTAL');

  static const $core.List<ProductMessageRequest_Orientation> values =
      <ProductMessageRequest_Orientation>[
    ORIENTATION_UNSPECIFIED,
    ORIENTATION_VERTICAL,
    ORIENTATION_HORIZONTAL,
  ];

  static final $core.List<ProductMessageRequest_Orientation?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static ProductMessageRequest_Orientation? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ProductMessageRequest_Orientation._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
