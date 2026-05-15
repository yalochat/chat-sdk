// Copyright (c) Yalochat, Inc. All rights reserved.

import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { html, LitElement } from 'lit';
import { customElement } from 'lit/decorators.js';
import { ContextProvider } from '@lit/context';
import {
  defaultIcons,
  type YaloChatClientConfig,
} from '@domain/config/chat-config';
import { yaloChatClientConfigContext } from '@domain/config/chat-config-context';
import { loggerContext, type Logger } from '@log/logger-context';
import type { ChatMessage } from '@domain/models/chat-message/chat-message';
import './chat-footer';
import type { ChatFooter } from './chat-footer';

const config: YaloChatClientConfig = {
  channelId: 'ch-1',
  organizationId: 'org-1',
  channelName: 'Test',
  target: 'target',
  icons: defaultIcons,
};

const noopLogger: Logger = {
  debug: () => {},
  info: () => {},
  warn: () => {},
  error: () => {},
} as unknown as Logger;

@customElement('test-footer-context-provider')
class TestFooterContextProvider extends LitElement {
  _configProvider = new ContextProvider(this, {
    context: yaloChatClientConfigContext,
    initialValue: config,
  });
  _loggerProvider = new ContextProvider(this, {
    context: loggerContext,
    initialValue: noopLogger,
  });

  render() {
    return html`<slot></slot>`;
  }
}

const renderFooter = async (): Promise<ChatFooter> => {
  const wrapper = document.createElement(
    'test-footer-context-provider'
  ) as TestFooterContextProvider;
  const footer = document.createElement('chat-footer') as ChatFooter;
  wrapper.appendChild(footer);
  document.body.appendChild(wrapper);
  await wrapper.updateComplete;
  await footer.updateComplete;
  return footer;
};

const getFilePicker = (footer: ChatFooter): HTMLInputElement =>
  footer.shadowRoot!.querySelector('#file-picker') as HTMLInputElement;

const getActionButton = (footer: ChatFooter): HTMLButtonElement =>
  footer.shadowRoot!.querySelector('.chat-action-button') as HTMLButtonElement;

const getWaveformRecorder = (footer: ChatFooter): Element | null =>
  footer.shadowRoot!.querySelector('waveform-recorder');

const fireFilePicked = (input: HTMLInputElement, files: File[]) => {
  Object.defineProperty(input, 'files', {
    value: files,
    configurable: true,
  });
  input.dispatchEvent(new Event('change', { bubbles: true, composed: true }));
};

// --- Browser API stubs for the real AudioRecordingController ---

class FakeMediaStreamTrack {
  stop = vi.fn();
}
class FakeMediaStream {
  private _tracks = [new FakeMediaStreamTrack()];
  getTracks() {
    return this._tracks;
  }
}
class FakeAnalyser {
  fftSize = 256;
  frequencyBinCount = 128;
  getByteFrequencyData(data: Uint8Array) {
    data.fill(64);
  }
}
class FakeAudioContext {
  createMediaStreamSource() {
    return { connect: () => {} };
  }
  createAnalyser() {
    return new FakeAnalyser();
  }
  close = vi.fn();
}
class FakeMediaRecorder {
  static isTypeSupported = () => true;
  state: 'inactive' | 'recording' = 'inactive';
  mimeType: string;
  ondataavailable: ((e: { data: Blob }) => void) | null = null;
  onstop: (() => void) | null = null;
  constructor(_stream: unknown, options?: { mimeType?: string }) {
    this.mimeType = options?.mimeType ?? 'audio/webm';
  }
  start() {
    this.state = 'recording';
    this.ondataavailable?.({
      data: new Blob(['chunk'], { type: this.mimeType }),
    });
  }
  stop() {
    this.state = 'inactive';
    this.onstop?.();
  }
}

let getUserMediaImpl: () => Promise<FakeMediaStream>;

const installAudioStubs = () => {
  getUserMediaImpl = () => Promise.resolve(new FakeMediaStream());
  Object.defineProperty(navigator, 'mediaDevices', {
    configurable: true,
    value: {
      getUserMedia: vi.fn(() => getUserMediaImpl()),
    },
  });
  vi.stubGlobal('MediaRecorder', FakeMediaRecorder);
  vi.stubGlobal('AudioContext', FakeAudioContext);
};

const flushMicrotasks = () => new Promise((r) => setTimeout(r, 0));

const startRecordingViaUI = async (footer: ChatFooter) => {
  getActionButton(footer).click();
  await flushMicrotasks();
  await footer.updateComplete;
};

describe('ChatFooter', () => {
  beforeEach(() => {
    installAudioStubs();
  });

  afterEach(() => {
    document.body.innerHTML = '';
    vi.unstubAllGlobals();
    vi.restoreAllMocks();
  });

  describe('file picker', () => {
    it('dispatches yalo-chat-send-image-message with an image ChatMessage when an image is picked', async () => {
      const footer = await renderFooter();
      const file = new File(['data'], 'photo.png', { type: 'image/png' });

      const received = new Promise<{ message: ChatMessage; file: File }>(
        (resolve) => {
          footer.addEventListener(
            'yalo-chat-send-image-message',
            (e) =>
              resolve(
                (e as CustomEvent<{ message: ChatMessage; file: File }>).detail
              ),
            { once: true }
          );
        }
      );

      fireFilePicked(getFilePicker(footer), [file]);
      const detail = await received;

      expect(detail.file).toBe(file);
      expect(detail.message).toMatchObject({
        type: 'image',
        role: 'USER',
        fileName: 'photo.png',
        mediaType: 'image/png',
        byteCount: file.size,
        content: '',
      });
      expect(detail.message.blob).toBe(file);
    });

    it('dispatches yalo-chat-send-attachment-message for non-image files', async () => {
      const footer = await renderFooter();
      const file = new File(['pdf data'], 'doc.pdf', {
        type: 'application/pdf',
      });

      const received = new Promise<{ message: ChatMessage; file: File }>(
        (resolve) => {
          footer.addEventListener(
            'yalo-chat-send-attachment-message',
            (e) =>
              resolve(
                (e as CustomEvent<{ message: ChatMessage; file: File }>).detail
              ),
            { once: true }
          );
        }
      );

      fireFilePicked(getFilePicker(footer), [file]);
      const detail = await received;

      expect(detail.message).toMatchObject({
        type: 'attachment',
        role: 'USER',
        fileName: 'doc.pdf',
        mediaType: 'application/pdf',
        byteCount: file.size,
        content: '',
      });
    });

    it('does not dispatch when no file is selected', async () => {
      const footer = await renderFooter();
      let emitted = false;
      footer.addEventListener('yalo-chat-send-image-message', () => {
        emitted = true;
      });
      footer.addEventListener('yalo-chat-send-attachment-message', () => {
        emitted = true;
      });

      fireFilePicked(getFilePicker(footer), []);

      expect(emitted).toBe(false);
    });

    it('clears the input value after a file is picked so the same file can be reselected', async () => {
      const footer = await renderFooter();
      const file = new File(['data'], 'photo.png', { type: 'image/png' });
      const input = getFilePicker(footer);
      input.value = '';

      fireFilePicked(input, [file]);

      expect(input.value).toBe('');
    });
  });

  describe('action button icon', () => {
    it('renders the mic icon when the textarea is empty and not recording', async () => {
      const footer = await renderFooter();

      expect(getActionButton(footer).textContent).toContain('mic');
    });

    it('renders the send icon when the textarea has content', async () => {
      const footer = await renderFooter();
      const textarea = footer.shadowRoot!.querySelector(
        '.chat-input'
      ) as HTMLTextAreaElement;
      textarea.value = 'Hello';
      textarea.dispatchEvent(
        new Event('input', { bubbles: true, composed: true })
      );
      await footer.updateComplete;

      expect(getActionButton(footer).textContent).toContain('send');
    });
  });

  describe('voice recording', () => {
    it('enters recording mode and renders the waveform-recorder when the action button is clicked with no text', async () => {
      const footer = await renderFooter();

      await startRecordingViaUI(footer);

      expect(getWaveformRecorder(footer)).not.toBeNull();
      expect(getActionButton(footer).textContent).toContain('send');
    });

    it('dispatches yalo-chat-send-voice-message when the action button is clicked while recording', async () => {
      const footer = await renderFooter();
      await startRecordingViaUI(footer);

      const received = new Promise<{ message: ChatMessage; blob: Blob }>(
        (resolve) => {
          footer.addEventListener(
            'yalo-chat-send-voice-message',
            (e) =>
              resolve(
                (e as CustomEvent<{ message: ChatMessage; blob: Blob }>).detail
              ),
            { once: true }
          );
        }
      );

      getActionButton(footer).click();
      const detail = await received;

      expect(detail.blob).toBeInstanceOf(Blob);
      expect(detail.blob.size).toBeGreaterThan(0);
      expect(detail.message).toMatchObject({
        type: 'voice',
        role: 'USER',
      });
      expect(detail.message.amplitudes).toHaveLength(40);
      expect(detail.message.fileName).toMatch(/^voice-\d+\.webm$/);
      expect(detail.message.blob).toBe(detail.blob);
    });

    it('returns to idle without sending a voice message when the waveform-recorder dispatches stop', async () => {
      const footer = await renderFooter();
      await startRecordingViaUI(footer);

      let sent = false;
      footer.addEventListener('yalo-chat-send-voice-message', () => {
        sent = true;
      });

      getWaveformRecorder(footer)!.dispatchEvent(
        new CustomEvent('yalo-chat-stop-voice-message', {
          bubbles: true,
          composed: true,
        })
      );
      await flushMicrotasks();
      await footer.updateComplete;

      expect(sent).toBe(false);
      expect(getWaveformRecorder(footer)).toBeNull();
      expect(getActionButton(footer).textContent).toContain('mic');
    });

    it('stays idle when microphone access is denied', async () => {
      getUserMediaImpl = () => Promise.reject(new Error('denied'));
      const footer = await renderFooter();

      await startRecordingViaUI(footer);

      expect(getWaveformRecorder(footer)).toBeNull();
      expect(getActionButton(footer).textContent).toContain('mic');
    });

    it('updates the elapsed time on the waveform-recorder as time passes', async () => {
      vi.useFakeTimers();
      try {
        const footer = await renderFooter();
        getActionButton(footer).click();
        await vi.advanceTimersByTimeAsync(0);
        await footer.updateComplete;

        expect(getWaveformRecorder(footer)?.getAttribute('time')).toBe('00:00');

        await vi.advanceTimersByTimeAsync(1_100);
        await footer.updateComplete;

        expect(getWaveformRecorder(footer)?.getAttribute('time')).toBe('00:01');
      } finally {
        vi.useRealTimers();
      }
    });
  });
});
