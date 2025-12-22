// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/common/format.dart';
import 'package:chat_flutter_sdk/src/ui/theme/view_models/theme_cubit.dart';
import 'package:chat_flutter_sdk/ui/theme/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductMessagePrice extends StatelessWidget {
  final double price;
  final double? salePrice;
  final double? pricePerSubunit;
  const ProductMessagePrice({
    super.key,
    required this.price,
    this.salePrice,
    this.pricePerSubunit,
  });

  @override
  Widget build(BuildContext context) {
    final chatThemeCubit = context.watch<ChatThemeCubit>();
    final priceToShow = salePrice != null ? salePrice! : price;
    final double? oldPrice = salePrice != null ? price : null;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(SdkConstants.productPricePadding),
            decoration: BoxDecoration(
              color: chatThemeCubit.state.productPriceBackgroundColor,
              borderRadius: BorderRadius.circular(
                SdkConstants.productPriceBorderRadius,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  chatThemeCubit.state.currencyIcon,
                  size: SdkConstants.productPriceIconSize,
                  color: chatThemeCubit.state.currencyIconColor,
                ),
                SizedBox(width: SdkConstants.rowItemSpace),
                Text(
                  context.formatCurrency(priceToShow),
                  style: chatThemeCubit.state.productPriceStyle,
                ),
                SizedBox(width: SdkConstants.rowItemSpace),
                if (oldPrice != null)
                  Text(
                    context.formatCurrency(oldPrice),
                    style: chatThemeCubit.state.productSalePriceStrikeStyle,
                  ),
              ],
            ),
          ),
          SizedBox(width: SdkConstants.rowItemSpace),
          if (pricePerSubunit != null)
            Row(
              children: [
                Icon(
                  chatThemeCubit.state.currencyIcon,
                  color: chatThemeCubit.state.pricePerSubunitColor,
                  size: SdkConstants.productPriceIconSize,
                ),
                SizedBox(width: SdkConstants.rowItemSpace),
                Text(
                  context.formatCurrency(pricePerSubunit!),
                  style: chatThemeCubit.state.pricePerSubunitStyle,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
