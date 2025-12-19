// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/l10n/yalo_sdk_localizations.dart';
import 'package:chat_flutter_sdk/l10n/yalo_sdk_localizations_en.g.dart';
import 'package:flutter/widgets.dart';

extension Translation on BuildContext {
  static YaloSdkLocalizations? _translate;

  YaloSdkLocalizations get translate {
    _translate ??= YaloSdkLocalizations.of(this) ?? YaloSdkLocalizationsEn();
    return _translate!;
  }

  @visibleForTesting
  void cleanTranslate() {
    _translate = null;
  }
}
