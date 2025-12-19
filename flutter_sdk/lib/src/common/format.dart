// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension Formatter on BuildContext {
  static NumberFormat? _numberFormatter;
  static NumberFormat? _currencyFormatter;

  String formatCurrency(double val) {
    Locale locale = Localizations.localeOf(this);
    if (_currencyFormatter == null ||
        _currencyFormatter!.locale != locale.toString()) {
      _currencyFormatter = NumberFormat.currency(locale: locale.toString());
    }
    return _currencyFormatter!.format(val);
  }

  String formatNumber(double val) {
    Locale locale = Localizations.localeOf(this);
    if (_numberFormatter == null ||
        _numberFormatter!.locale != locale.toString()) {
      _numberFormatter = NumberFormat.decimalPattern(locale.toString());
    }
    return _numberFormatter!.format(val);
  }
}
