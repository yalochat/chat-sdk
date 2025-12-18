// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension Formatter on BuildContext {
  static final _numberFormatter = NumberFormat.decimalPattern();
  static final _currencyFormatter = NumberFormat.currency();

  String formatCurrency(double val) => _currencyFormatter.format(val);

  String formatNumber(double val) => _numberFormatter.format(val);
}
