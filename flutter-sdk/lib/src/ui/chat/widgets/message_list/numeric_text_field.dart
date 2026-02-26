// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/common/format.dart';
import 'package:chat_flutter_sdk/src/ui/theme/view_models/theme_cubit.dart';
import 'package:chat_flutter_sdk/ui/theme/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

class NumericTextField extends StatefulWidget {
  final String unitName;
  final double value;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final ValueChanged<double>? onEditingComplete;
  const NumericTextField({
    super.key,
    required this.value,
    required this.onAdd,
    required this.onRemove,
    this.onEditingComplete,
    required this.unitName,
  });

  @override
  State<NumericTextField> createState() => _NumericTextFieldState();
}

class _NumericTextFieldState extends State<NumericTextField> {
  late TextEditingController _textEditingController;
  late FocusNode _focusNode;

  void _handleFocus() {
    if (_focusNode.hasFocus) {
      _textEditingController.text = _textEditingController.text.split(' ')[0];
    } else {
      final value = _textEditingController.text;
      double valNum = double.parse(value);
      if (widget.onEditingComplete != null) {
        widget.onEditingComplete!(valNum);
      }

      _textEditingController.text =
          '${context.formatNumber(widget.value)} ${widget.unitName}';
    }
  }

  @override
  void initState() {
    _textEditingController = TextEditingController();
    _focusNode = FocusNode();

    _focusNode.addListener(_handleFocus);
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatThemeCubit = context.watch<ChatThemeCubit>();
    _textEditingController.text =
        '${context.formatNumber(widget.value)} ${widget.unitName}';
    return Row(
      children: [
        IconButton(
          onPressed: widget.onRemove,
          icon: Icon(
            chatThemeCubit.state.removeIcon,
            color: chatThemeCubit.state.numericControlIconColor,
          ),
        ),
        SizedBox(width: SdkConstants.rowItemSpace),
        Expanded(
          child: TextField(
            textAlign: TextAlign.center,
            decoration: InputDecoration(border: InputBorder.none),
            keyboardType: TextInputType.number,
            controller: _textEditingController,
            focusNode: _focusNode,
            onEditingComplete: () {
              _focusNode.unfocus();
            },
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ),
        SizedBox(width: SdkConstants.rowItemSpace),
        IconButton(
          onPressed: widget.onAdd,
          icon: Icon(
            chatThemeCubit.state.addIcon,
            color: chatThemeCubit.state.numericControlIconColor,
          ),
        ),
      ],
    );
  }
}
