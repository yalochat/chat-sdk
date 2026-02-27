// Copyright (c) Yalochat, Inc. All rights reserved.

import { SdkColors } from './colors.js';

/** Branding / colour configuration for the chat UI. */
export interface ChatTheme {
  backgroundColor: string;
  cardBackgroundColor: string;
  cardBorderColor: string;
  appBarBackgroundColor: string;
  userMessageColor: string;
  inputTextFieldColor: string;
  inputTextFieldBorderColor: string;
  sendButtonColor: string;
  sendButtonForegroundColor: string;
  waveColor: string;
  attachmentPickerBackgroundColor: string;
  actionIconColor: string;
  cancelRecordingIconColor: string;
  closeModalIconColor: string;
  playAudioIconColor: string;
  pauseAudioIconColor: string;
  attachIconColor: string;
  cameraIconColor: string;
  galleryIconColor: string;
  trashIconColor: string;
  currencyIconColor: string;
  numericControlIconColor: string;
  imagePlaceholderBackgroundColor: string;
  imagePlaceholderIconColor: string;
  productPriceBackgroundColor: string;
  pricePerSubunitColor: string;
  pickerButtonBorderColor: string;
  quickReplyColor: string;
  quickReplyBorderColor: string;

  // Text colours
  userMessageTextColor: string;
  assistantMessageTextColor: string;
  hintTextColor: string;
  timerTextColor: string;
  modalHeaderColor: string;
  productTitleColor: string;
  productSubunitsColor: string;
  productPriceColor: string;
  productSalePriceStrikeColor: string;
  pricePerSubunitTextColor: string;
  expandControlsColor: string;
  quickReplyTextColor: string;
}

export const defaultChatTheme: ChatTheme = {
  backgroundColor: SdkColors.backgroundColorLight,
  cardBackgroundColor: SdkColors.backgroundColorLight,
  cardBorderColor: SdkColors.cardBorderColorLight,
  appBarBackgroundColor: SdkColors.appBarBackgroundColorLight,
  userMessageColor: SdkColors.userMessageColorLight,
  inputTextFieldColor: SdkColors.inputTextFieldColorLight,
  inputTextFieldBorderColor: SdkColors.inputTextFieldBorderColorLight,
  sendButtonColor: SdkColors.sendButtonColorLight,
  sendButtonForegroundColor: SdkColors.sendButtonTextColorLight,
  waveColor: SdkColors.waveColorLight,
  attachmentPickerBackgroundColor: SdkColors.attachmentPickerBackgroundColorLight,
  actionIconColor: '#000000',
  cancelRecordingIconColor: SdkColors.messageControlIconColorLight,
  closeModalIconColor: SdkColors.messageControlIconColorLight,
  playAudioIconColor: SdkColors.messageControlIconColorLight,
  pauseAudioIconColor: SdkColors.messageControlIconColorLight,
  attachIconColor: SdkColors.messageControlIconColorLight,
  cameraIconColor: SdkColors.messageControlIconColorLight,
  galleryIconColor: SdkColors.messageControlIconColorLight,
  trashIconColor: SdkColors.iconWithBackdropColorLight,
  currencyIconColor: SdkColors.priceColorLight,
  numericControlIconColor: SdkColors.messageControlIconColorLight,
  imagePlaceholderBackgroundColor: SdkColors.imagePlaceHolderColorLight,
  imagePlaceholderIconColor: SdkColors.messageControlIconColorLight,
  productPriceBackgroundColor: SdkColors.discountBackgroundColorLight,
  pricePerSubunitColor: SdkColors.productCardSubtitleColorLight,
  pickerButtonBorderColor: SdkColors.pickerButtonBorderColor,
  quickReplyColor: SdkColors.userMessageColorLight,
  quickReplyBorderColor: SdkColors.quickReplyBorderColor,
  userMessageTextColor: SdkColors.userMessageTextColorLight,
  assistantMessageTextColor: SdkColors.assistantMessageTextColorLight,
  hintTextColor: SdkColors.hintColorLight,
  timerTextColor: SdkColors.timerColorLight,
  modalHeaderColor: SdkColors.modalHeaderColorLight,
  productTitleColor: SdkColors.assistantMessageTextColorLight,
  productSubunitsColor: SdkColors.productCardSubtitleColorLight,
  productPriceColor: SdkColors.priceColorLight,
  productSalePriceStrikeColor: SdkColors.discountStrikeColorLight,
  pricePerSubunitTextColor: SdkColors.pricePerUnitColorLight,
  expandControlsColor: SdkColors.expandControlColorLight,
  quickReplyTextColor: SdkColors.userMessageTextColorLight,
};

/** Applies a ChatTheme as CSS custom properties on the given element. */
export function applyTheme(theme: ChatTheme, element: HTMLElement): void {
  const s = element.style;
  s.setProperty('--yalo-bg-color', theme.backgroundColor);
  s.setProperty('--yalo-card-bg-color', theme.cardBackgroundColor);
  s.setProperty('--yalo-card-border-color', theme.cardBorderColor);
  s.setProperty('--yalo-app-bar-bg-color', theme.appBarBackgroundColor);
  s.setProperty('--yalo-user-msg-color', theme.userMessageColor);
  s.setProperty('--yalo-input-color', theme.inputTextFieldColor);
  s.setProperty('--yalo-input-border-color', theme.inputTextFieldBorderColor);
  s.setProperty('--yalo-send-btn-color', theme.sendButtonColor);
  s.setProperty('--yalo-send-btn-fg-color', theme.sendButtonForegroundColor);
  s.setProperty('--yalo-wave-color', theme.waveColor);
  s.setProperty('--yalo-attachment-bg-color', theme.attachmentPickerBackgroundColor);
  s.setProperty('--yalo-action-icon-color', theme.actionIconColor);
  s.setProperty('--yalo-cancel-rec-icon-color', theme.cancelRecordingIconColor);
  s.setProperty('--yalo-play-icon-color', theme.playAudioIconColor);
  s.setProperty('--yalo-pause-icon-color', theme.pauseAudioIconColor);
  s.setProperty('--yalo-attach-icon-color', theme.attachIconColor);
  s.setProperty('--yalo-camera-icon-color', theme.cameraIconColor);
  s.setProperty('--yalo-gallery-icon-color', theme.galleryIconColor);
  s.setProperty('--yalo-trash-icon-color', theme.trashIconColor);
  s.setProperty('--yalo-currency-icon-color', theme.currencyIconColor);
  s.setProperty('--yalo-numeric-ctrl-icon-color', theme.numericControlIconColor);
  s.setProperty('--yalo-img-placeholder-bg-color', theme.imagePlaceholderBackgroundColor);
  s.setProperty('--yalo-img-placeholder-icon-color', theme.imagePlaceholderIconColor);
  s.setProperty('--yalo-product-price-bg-color', theme.productPriceBackgroundColor);
  s.setProperty('--yalo-price-per-subunit-color', theme.pricePerSubunitColor);
  s.setProperty('--yalo-picker-btn-border-color', theme.pickerButtonBorderColor);
  s.setProperty('--yalo-quick-reply-color', theme.quickReplyColor);
  s.setProperty('--yalo-quick-reply-border-color', theme.quickReplyBorderColor);
  s.setProperty('--yalo-user-msg-text-color', theme.userMessageTextColor);
  s.setProperty('--yalo-assistant-msg-text-color', theme.assistantMessageTextColor);
  s.setProperty('--yalo-hint-text-color', theme.hintTextColor);
  s.setProperty('--yalo-timer-text-color', theme.timerTextColor);
  s.setProperty('--yalo-modal-header-color', theme.modalHeaderColor);
  s.setProperty('--yalo-product-title-color', theme.productTitleColor);
  s.setProperty('--yalo-product-subunits-color', theme.productSubunitsColor);
  s.setProperty('--yalo-product-price-color', theme.productPriceColor);
  s.setProperty('--yalo-product-sale-strike-color', theme.productSalePriceStrikeColor);
  s.setProperty('--yalo-price-per-subunit-text-color', theme.pricePerSubunitTextColor);
  s.setProperty('--yalo-expand-controls-color', theme.expandControlsColor);
  s.setProperty('--yalo-quick-reply-text-color', theme.quickReplyTextColor);
}
