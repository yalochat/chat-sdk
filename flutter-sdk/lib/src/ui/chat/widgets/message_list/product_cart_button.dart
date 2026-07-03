// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:yalo_chat_flutter_sdk/domain/models/product/product.dart';
import 'package:yalo_chat_flutter_sdk/src/common/translation.dart';
import 'package:yalo_chat_flutter_sdk/src/domain/models/chat_message/chat_message.dart';
import 'package:yalo_chat_flutter_sdk/src/ui/chat/view_models/messages/messages_bloc.dart';
import 'package:yalo_chat_flutter_sdk/src/ui/chat/view_models/messages/messages_event.dart';
import 'package:yalo_chat_flutter_sdk/src/ui/theme/view_models/theme_cubit.dart';
import 'package:yalo_chat_flutter_sdk/ui/theme/chat_theme.dart';
import 'package:yalo_chat_flutter_sdk/ui/theme/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum _CartButtonState { notAdded, inCart, modified }

// Button of a product card that sends the selected quantities to the cart as
// an update cart product request. Once pressed it is disabled and shows a
// check icon, a state that is persisted so it survives reopening the chat.
// Changing the quantities afterwards re-enables it so the cart can be updated
// with the new amounts.
class ProductCartButton extends StatefulWidget {
  final ChatMessage message;
  final Product product;

  const ProductCartButton({
    super.key,
    required this.message,
    required this.product,
  });

  @override
  State<ProductCartButton> createState() => _ProductCartButtonState();
}

class _ProductCartButtonState extends State<ProductCartButton> {
  _CartButtonState? _cartState;

  _CartButtonState get _effectiveCartState {
    if (_cartState != null) {
      return _cartState!;
    }
    return widget.product.inCart
        ? _CartButtonState.inCart
        : _CartButtonState.notAdded;
  }

  @override
  void didUpdateWidget(ProductCartButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.product.sku != widget.product.sku) {
      _cartState = null;
      return;
    }
    if (_effectiveCartState != _CartButtonState.inCart) {
      return;
    }
    final bool quantityChanged =
        oldWidget.product.unitsAdded != widget.product.unitsAdded ||
        oldWidget.product.subunitsAdded != widget.product.subunitsAdded;
    if (quantityChanged) {
      _cartState = _CartButtonState.modified;
    }
  }

  String _label(BuildContext context) {
    return switch (_effectiveCartState) {
      _CartButtonState.inCart => context.translate.inTheCart,
      _CartButtonState.modified => context.translate.updateTheCart,
      _CartButtonState.notAdded => context.translate.addToCart,
    };
  }

  void _addToCart(BuildContext context) {
    setState(() {
      _cartState = _CartButtonState.inCart;
    });
    context.read<MessagesBloc>().add(
      ChatAddProductToCart(
        messageId: widget.message.id!,
        productSku: widget.product.sku,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ChatTheme chatTheme = context.watch<ChatThemeCubit>().chatTheme;
    final bool inCart = _effectiveCartState == _CartButtonState.inCart;

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        key: const Key('product_cart_button'),
        style: FilledButton.styleFrom(
          backgroundColor: inCart
              ? chatTheme.productCardButtonInCartColor
              : chatTheme.productCardButtonColor,
          foregroundColor: inCart
              ? chatTheme.productCardButtonInCartForegroundColor
              : chatTheme.productCardButtonForegroundColor,
          disabledBackgroundColor: chatTheme.productCardButtonInCartColor,
          disabledForegroundColor:
              chatTheme.productCardButtonInCartForegroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              SdkConstants.messageBorderRadius / 2,
            ),
          ),
        ),
        onPressed: inCart ? null : () => _addToCart(context),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (inCart) ...[
              Icon(
                chatTheme.productCardInCartIcon,
                size: SdkConstants.titleFontSize,
              ),
              const SizedBox(width: SdkConstants.rowItemSpace / 2),
            ],
            Flexible(child: Text(_label(context))),
          ],
        ),
      ),
    );
  }
}
