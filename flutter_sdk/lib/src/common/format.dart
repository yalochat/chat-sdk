// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/l10n/yalo_sdk_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

extension Formatter on BuildContext {
  static final _numberFormatter = NumberFormat.decimalPattern();
  static final _currencyFormatter = NumberFormat.currency();
  static YaloSdkLocalizations? _translate;

  String formatCurrency(double val) => _currencyFormatter.format(val);

  String formatNumber(double val) => _numberFormatter.format(val);

  YaloSdkLocalizations get translate {
    _translate ??= read<YaloSdkLocalizations>();
    return _translate!;
  }
}
