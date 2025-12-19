// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:io';

import 'package:chat_flutter_sdk/domain/models/product/product.dart';
import 'package:chat_flutter_sdk/src/common/format.dart';
import 'package:chat_flutter_sdk/src/domain/models/chat_message/chat_message.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/messages/messages_bloc.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/messages/messages_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../ui/theme/constants.dart';
import '../../../theme/view_models/theme_cubit.dart';
import 'image_placeholder.dart';
import 'numeric_text_field.dart';
import 'product_message_price.dart';

class ProductHorizontalCard extends StatelessWidget {
  final ChatMessage message;
  final Product product;
  const ProductHorizontalCard({
    super.key,
    required this.message,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final chatThemeCubit = context.watch<ChatThemeCubit>();
    final messagesBloc = context.read<MessagesBloc>();
    Widget productImage;
    if (product.imagesUrl.isEmpty) {
      productImage = ImagePlaceholder();
    } else {
      final imageUrl = product.imagesUrl[0];
      ImageProvider provider;
      if (imageUrl.startsWith('http')) {
        provider = NetworkImage(imageUrl);
      } else if (imageUrl.startsWith('assets/')) {
        provider = AssetImage(imageUrl);
      } else {
        provider = FileImage(File(imageUrl));
      }

      productImage = Image(image: provider);
    }

    final subunitsText = product.subunits > 1
        ? product.subunitNamePlural
        : product.subunitName;

    final orientation = MediaQuery.orientationOf(context);
    final imageAspectRatio = orientation == Orientation.portrait
        ? 9.0 / 16.0
        : 4.0 / 3.0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          flex: 2,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              SdkConstants.productImageBorderRadius,
            ),
            child: AspectRatio(aspectRatio: imageAspectRatio, child: productImage),
          ),
        ),
        SizedBox(width: SdkConstants.rowItemSpace),
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.name, style: chatThemeCubit.state.productTitleStyle),
              Text(
                '${context.formatNumber(product.subunits)} $subunitsText',
                style: chatThemeCubit.state.productSubunitsStyle,
              ),
              ProductMessagePrice(
                price: product.price,
                salePrice: product.salePrice,
                pricePerSubunit: product.price / product.subunits,
              ),
              NumericTextField(
                value: product.unitsAdded,
                unitName: product.unitName,
                unitNamePlural: product.unitNamePlural,
                onAdd: () {
                  messagesBloc.add(
                    ChatUpdateProductQuantity(
                      messageId: message.id!,
                      productSku: product.sku,
                      unitType: UnitType.unit,
                      quantity: product.unitsAdded + product.unitStep,
                    ),
                  );
                },
                onRemove: () {
                  messagesBloc.add(
                    ChatUpdateProductQuantity(
                      messageId: message.id!,
                      productSku: product.sku,
                      unitType: UnitType.unit,
                      quantity: product.unitsAdded - product.unitStep,
                    ),
                  );
                },
                onEditingComplete: (value) {
                  messagesBloc.add(
                    ChatUpdateProductQuantity(
                      messageId: message.id!,
                      productSku: product.sku,
                      unitType: UnitType.unit,
                      quantity: value,
                    ),
                  );
                },
              ),
              if (product.subunitName != null &&
                  product.subunitNamePlural != null)
                NumericTextField(
                  value: product.subunitsAdded,
                  unitName: product.subunitName!,
                  unitNamePlural: product.subunitNamePlural!,
                  onAdd: () {
                    messagesBloc.add(
                      ChatUpdateProductQuantity(
                        messageId: message.id!,
                        productSku: product.sku,
                        unitType: UnitType.subunit,
                        quantity: product.subunitsAdded + product.subunitStep,
                      ),
                    );
                  },
                  onRemove: () {
                    messagesBloc.add(
                      ChatUpdateProductQuantity(
                        messageId: message.id!,
                        productSku: product.sku,
                        unitType: UnitType.subunit,
                        quantity: product.subunitsAdded - product.subunitStep,
                      ),
                    );
                  },
                  onEditingComplete: (value) {
                    messagesBloc.add(
                      ChatUpdateProductQuantity(
                        messageId: message.id!,
                        productSku: product.sku,
                        unitType: UnitType.subunit,
                        quantity: value,
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}
