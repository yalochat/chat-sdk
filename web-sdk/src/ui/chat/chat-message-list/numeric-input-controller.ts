// Copyright (c) Yalochat, Inc. All rights reserved.

import type { ReactiveController } from 'lit';
import type { NumericInput } from './numeric-input';

export default class NumericInputController implements ReactiveController {
  host: NumericInput;

  private _focused = false;

  constructor(host: NumericInput) {
    this.host = host;
    this.host.addController(this);
  }

  hostConnected() {}

  get displayValue(): string {
    const { value, unitName } = this.host;
    if (this._focused) return value === 0 ? '' : String(value);
    return unitName ? `${value} ${unitName}` : String(value);
  }

  get removeDisabled(): boolean {
    return this.host.value - this.host.step < this.host.min;
  }

  onAdd = () => {
    this._emit('yalo-chat-numeric-add', this.host.value + this.host.step);
  };

  onRemove = () => {
    if (this.removeDisabled) return;
    this._emit('yalo-chat-numeric-remove', this.host.value - this.host.step);
  };

  onFocus = () => {
    this._focused = true;
    this.host.requestUpdate();
  };

  onBlur = () => {
    this._focused = false;
    const parsed = Number(this.host.inputElement.value);
    if (Number.isFinite(parsed) && parsed !== this.host.value) {
      this._emit('yalo-chat-numeric-change', Math.max(this.host.min, parsed));
    }
    this.host.requestUpdate();
  };

  onKeyDown = (e: KeyboardEvent) => {
    if (e.key === 'Enter') this.host.inputElement.blur();
  };

  onBeforeInput = (e: InputEvent) => {
    if (e.data !== null && !/^\d+$/.test(e.data)) {
      e.preventDefault();
    }
  };

  private _emit(name: string, value: number) {
    this.host.dispatchEvent(
      new CustomEvent(name, {
        detail: { value },
        bubbles: true,
        composed: true,
      })
    );
  }
}
