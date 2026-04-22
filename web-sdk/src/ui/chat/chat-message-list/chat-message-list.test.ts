// Copyright (c) Yalochat, Inc. All rights reserved.

import { afterEach, describe, expect, it, vi } from 'vitest';
import { html, LitElement } from 'lit';
import { customElement } from 'lit/decorators.js';
import { ContextProvider } from '@lit/context';
import { yaloChatClientConfigContext } from '@domain/config/chat-config-context';
import type { YaloChatClientConfig } from '@domain/config/chat-config';
import { loggerContext, type Logger } from '@log/logger-context';
import { ChatMessage } from '@domain/models/chat-message/chat-message';
import { Product } from '@domain/models/product/product';
import './chat-message-list';
import type ChatMessageList from './chat-message-list';

const config: YaloChatClientConfig = {
  channelId: 'ch-1',
  organizationId: 'org-1',
  channelName: 'Test',
  target: 'target',
};

const noopLogger: Logger = {
  info: () => {},
  warning: () => {},
  severe: () => {},
} as unknown as Logger;

@customElement('test-context-provider')
class TestContextProvider extends LitElement {
  // These providers are consumed by child components via @lit/context.
  // The fields are unused directly but must exist for context propagation.
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

const renderList = async (messages: ChatMessage[]) => {
  const wrapper = document.createElement(
    'test-context-provider'
  ) as TestContextProvider;
  const list = document.createElement('chat-message-list') as ChatMessageList;
  list.chatMessages = messages;
  wrapper.appendChild(list);
  document.body.appendChild(wrapper);
  await wrapper.updateComplete;
  await list.updateComplete;
  return list;
};

const timestamp = new Date('2026-01-01T00:00:00Z');

const buildProduct = (
  overrides: Partial<ConstructorParameters<typeof Product>[0]> = {}
) =>
  new Product({
    sku: 'sku-1',
    name: 'Sample',
    price: 10,
    unitName: '{amount, plural, one {unit} other {units}}',
    ...overrides,
  });

const getProductCard = async (list: ChatMessageList): Promise<LitElement> => {
  const assistant = list.shadowRoot!.querySelector(
    'assistant-message'
  ) as LitElement;
  await assistant.updateComplete;
  const productMsg = assistant.shadowRoot!.querySelector(
    'product-message'
  ) as LitElement;
  await productMsg.updateComplete;
  const card = productMsg.shadowRoot!.querySelector(
    'product-card'
  ) as LitElement;
  await card.updateComplete;
  return card;
};

describe('ChatMessageList', () => {
  afterEach(() => {
    document.body.innerHTML = '';
  });

  describe('assistant messages', () => {
    it('renders text as assistant-message with a <p> tag', async () => {
      const list = await renderList([
        ChatMessage.text({
          id: 1,
          role: 'AGENT',
          timestamp,
          content: 'Hello',
        }),
      ]);

      const assistant = list.shadowRoot!.querySelector('assistant-message');
      expect(assistant).not.toBeNull();
      const p = assistant!.shadowRoot!.querySelector('p');
      expect(p!.textContent).toContain('Hello');
    });

    it('renders voice as assistant-message with voice-message', async () => {
      const list = await renderList([
        ChatMessage.voice({
          id: 2,
          role: 'AGENT',
          timestamp,
          fileName: 'note.ogg',
          amplitudes: [0.1],
          duration: 3,
        }),
      ]);

      const assistant = list.shadowRoot!.querySelector('assistant-message');
      const bubble = assistant!.shadowRoot!.querySelector('.voice-bubble');
      expect(bubble!.querySelector('voice-message')).not.toBeNull();
    });

    it('renders image as assistant-message with image-message', async () => {
      const list = await renderList([
        ChatMessage.image({
          id: 3,
          role: 'AGENT',
          timestamp,
          fileName: 'photo.png',
        }),
      ]);

      const assistant = list.shadowRoot!.querySelector('assistant-message');
      const bubble = assistant!.shadowRoot!.querySelector('.image-bubble');
      expect(bubble!.querySelector('image-message')).not.toBeNull();
    });

    it('renders video as assistant-message with video-message', async () => {
      const list = await renderList([
        ChatMessage.video({
          id: 4,
          role: 'AGENT',
          timestamp,
          fileName: 'clip.mp4',
          duration: 10,
        }),
      ]);

      const assistant = list.shadowRoot!.querySelector('assistant-message');
      const bubble = assistant!.shadowRoot!.querySelector('.video-bubble');
      expect(bubble!.querySelector('video-message')).not.toBeNull();
    });

    it('renders attachment as assistant-message with attachment-message', async () => {
      const list = await renderList([
        ChatMessage.attachment({
          id: 5,
          role: 'AGENT',
          timestamp,
          fileName: 'doc.pdf',
        }),
      ]);

      const assistant = list.shadowRoot!.querySelector('assistant-message');
      const bubble = assistant!.shadowRoot!.querySelector('.attachment-bubble');
      expect(bubble!.querySelector('attachment-message')).not.toBeNull();
    });

    it('renders buttons as assistant-message with buttons-message', async () => {
      const list = await renderList([
        ChatMessage.buttons({
          id: 6,
          role: 'AGENT',
          timestamp,
          buttons: ['Yes', 'No'],
          content: 'Pick one',
        }),
      ]);

      const assistant = list.shadowRoot!.querySelector('assistant-message');
      const bubble = assistant!.shadowRoot!.querySelector('.buttons-bubble');
      expect(bubble!.querySelector('buttons-message')).not.toBeNull();
    });

    it('renders cta as assistant-message with cta-message', async () => {
      const list = await renderList([
        ChatMessage.cta({
          id: 7,
          role: 'AGENT',
          timestamp,
          ctaButtons: [{ text: 'Visit', url: 'https://example.com' }],
        }),
      ]);

      const assistant = list.shadowRoot!.querySelector('assistant-message');
      const bubble = assistant!.shadowRoot!.querySelector('.cta-bubble');
      expect(bubble!.querySelector('cta-message')).not.toBeNull();
    });

    it('renders product as a vertical product-message', async () => {
      const list = await renderList([
        ChatMessage.product({
          id: 40,
          role: 'AGENT',
          timestamp,
          products: [buildProduct({ sku: 'a' }), buildProduct({ sku: 'b' })],
        }),
      ]);

      const assistant = list.shadowRoot!.querySelector('assistant-message');
      const productMsg = assistant!.shadowRoot!.querySelector(
        '.product-bubble product-message'
      );
      expect(productMsg).not.toBeNull();
      expect(productMsg!.getAttribute('direction')).toBe('vertical');
      const cards = productMsg!.shadowRoot!.querySelectorAll('product-card');
      expect(cards).toHaveLength(2);
      cards.forEach((card) => {
        expect(
          (card as unknown as { layout: string }).layout
        ).toBe('horizontal');
      });
    });

    it('renders productCarousel as a horizontal product-message', async () => {
      const list = await renderList([
        ChatMessage.carousel({
          id: 41,
          role: 'AGENT',
          timestamp,
          products: [buildProduct({ sku: 'a' }), buildProduct({ sku: 'b' })],
        }),
      ]);

      const assistant = list.shadowRoot!.querySelector('assistant-message');
      const productMsg = assistant!.shadowRoot!.querySelector(
        '.product-bubble product-message'
      );
      expect(productMsg).not.toBeNull();
      expect(productMsg!.getAttribute('direction')).toBe('horizontal');
      const cards = productMsg!.shadowRoot!.querySelectorAll('product-card');
      expect(cards).toHaveLength(2);
      cards.forEach((card) => {
        expect(
          (card as unknown as { layout: string }).layout
        ).toBe('vertical');
      });
    });

    it('renders one numeric-input per product when there are no subunits', async () => {
      const list = await renderList([
        ChatMessage.product({
          id: 50,
          role: 'AGENT',
          timestamp,
          products: [buildProduct({ sku: 'a' })],
        }),
      ]);

      const card = await getProductCard(list);
      const inputs = card.shadowRoot!.querySelectorAll('numeric-input');
      expect(inputs).toHaveLength(1);
    });

    it('renders two numeric-inputs when the product has subunits', async () => {
      const list = await renderList([
        ChatMessage.product({
          id: 51,
          role: 'AGENT',
          timestamp,
          products: [
            buildProduct({
              sku: 'a',
              subunits: 6,
              subunitName: '{amount, plural, one {bag} other {bags}}',
            }),
          ],
        }),
      ]);

      const card = await getProductCard(list);
      const inputs = card.shadowRoot!.querySelectorAll('numeric-input');
      expect(inputs).toHaveLength(2);
    });

    it('emits yalo-chat-product-quantity-change with sku and unitType when clicking +/-', async () => {
      const list = await renderList([
        ChatMessage.product({
          id: 52,
          role: 'AGENT',
          timestamp,
          products: [
            buildProduct({
              sku: 'sku-xyz',
              unitsAdded: 2,
              subunits: 6,
              subunitsAdded: 1,
              subunitName: '{amount, plural, one {bag} other {bags}}',
            }),
          ],
        }),
      ]);

      const listener = vi.fn();
      list.addEventListener('yalo-chat-product-quantity-change', listener);

      const card = await getProductCard(list);
      const [unitInput, subunitInput] =
        card.shadowRoot!.querySelectorAll<LitElement>('numeric-input');
      await unitInput.updateComplete;
      await subunitInput.updateComplete;

      const unitButtons =
        unitInput.shadowRoot!.querySelectorAll<HTMLButtonElement>('button');
      const subunitButtons =
        subunitInput.shadowRoot!.querySelectorAll<HTMLButtonElement>('button');

      // Plus on units (value 2 + step 1 = 3)
      unitButtons[1].click();
      // Minus on subunits (value 1 - step 1 = 0)
      subunitButtons[0].click();

      expect(listener).toHaveBeenCalledTimes(2);
      expect((listener.mock.calls[0][0] as CustomEvent).detail).toMatchObject({
        messageId: 52,
        sku: 'sku-xyz',
        unitType: 'unit',
        value: 3,
      });
      expect((listener.mock.calls[1][0] as CustomEvent).detail).toMatchObject({
        messageId: 52,
        sku: 'sku-xyz',
        unitType: 'subunit',
        value: 0,
      });
    });

    it('collapses product lists past 3 items and toggles via Show more/less', async () => {
      const products = ['a', 'b', 'c', 'd'].map((sku) => buildProduct({ sku }));
      const list = await renderList([
        ChatMessage.product({
          id: 42,
          role: 'AGENT',
          timestamp,
          products,
        }),
      ]);

      const assistant = list.shadowRoot!.querySelector('assistant-message')!;
      const productMsg = assistant.shadowRoot!.querySelector(
        'product-message'
      )!;
      const initialCards =
        productMsg.shadowRoot!.querySelectorAll('product-card');
      const toggle = productMsg.shadowRoot!.querySelector(
        'button.expand'
      ) as HTMLButtonElement;

      expect(initialCards).toHaveLength(3);
      expect(toggle.textContent?.trim()).toBe('Show more');

      toggle.click();
      await (productMsg as LitElement).updateComplete;

      const expandedCards =
        productMsg.shadowRoot!.querySelectorAll('product-card');
      const expandedToggle = productMsg.shadowRoot!.querySelector(
        'button.expand'
      ) as HTMLButtonElement;
      expect(expandedCards).toHaveLength(4);
      expect(expandedToggle.textContent?.trim()).toBe('Show less');
    });

    it('falls back to text rendering for unknown type', async () => {
      const list = await renderList([
        new ChatMessage({
          id: 8,
          role: 'AGENT',
          type: 'unknown',
          timestamp,
          content: 'fallback',
        }),
      ]);

      const assistant = list.shadowRoot!.querySelector('assistant-message');
      const p = assistant!.shadowRoot!.querySelector('p');
      expect(p!.textContent).toContain('fallback');
    });
  });

  describe('user messages', () => {
    it('renders text as user-message with bubble content', async () => {
      const list = await renderList([
        ChatMessage.text({
          id: 10,
          role: 'USER',
          timestamp,
          content: 'Hi there',
        }),
      ]);

      const user = list.shadowRoot!.querySelector('user-message');
      expect(user).not.toBeNull();
      const bubble = user!.shadowRoot!.querySelector('.bubble');
      expect(bubble!.textContent).toContain('Hi there');
    });

    it('renders voice as user-message with voice-message', async () => {
      const list = await renderList([
        ChatMessage.voice({
          id: 11,
          role: 'USER',
          timestamp,
          fileName: 'rec.ogg',
          amplitudes: [0.2],
          duration: 4,
        }),
      ]);

      const user = list.shadowRoot!.querySelector('user-message');
      const bubble = user!.shadowRoot!.querySelector('.voice-bubble');
      expect(bubble!.querySelector('voice-message')).not.toBeNull();
    });

    it('renders image as user-message with image-message', async () => {
      const list = await renderList([
        ChatMessage.image({
          id: 12,
          role: 'USER',
          timestamp,
          fileName: 'selfie.jpg',
        }),
      ]);

      const user = list.shadowRoot!.querySelector('user-message');
      const bubble = user!.shadowRoot!.querySelector('.image-bubble');
      expect(bubble!.querySelector('image-message')).not.toBeNull();
    });

    it('renders attachment as user-message with attachment-message', async () => {
      const list = await renderList([
        ChatMessage.attachment({
          id: 13,
          role: 'USER',
          timestamp,
          fileName: 'report.pdf',
        }),
      ]);

      const user = list.shadowRoot!.querySelector('user-message');
      const bubble = user!.shadowRoot!.querySelector('.bubble');
      expect(bubble!.querySelector('attachment-message')).not.toBeNull();
    });

    it('falls back to text rendering for unknown type', async () => {
      const list = await renderList([
        new ChatMessage({
          id: 14,
          role: 'USER',
          type: 'unknown',
          timestamp,
          content: 'user fallback',
        }),
      ]);

      const user = list.shadowRoot!.querySelector('user-message');
      const bubble = user!.shadowRoot!.querySelector('.bubble');
      expect(bubble!.textContent).toContain('user fallback');
    });

    it('renders error icon and retry label when status is ERROR', async () => {
      const list = await renderList([
        ChatMessage.text({
          id: 15,
          role: 'USER',
          timestamp,
          content: 'failed message',
          status: 'ERROR',
        }),
      ]);

      const user = list.shadowRoot!.querySelector('user-message')!;
      await (user as LitElement).updateComplete;
      const wrapper = user.shadowRoot!.querySelector('.error-wrapper');
      expect(wrapper).not.toBeNull();

      const icon = user.shadowRoot!.querySelector('.error-icon');
      expect(icon).not.toBeNull();

      const label = user.shadowRoot!.querySelector('.error-label');
      expect(label!.textContent).toContain('Not delivered.');

      const retry = label!.querySelector('.retry');
      expect(retry).not.toBeNull();
      expect(retry!.textContent).toContain('Retry');
    });

    it('dispatches yalo-chat-retry-message when error message is clicked', async () => {
      const list = await renderList([
        ChatMessage.text({
          id: 16,
          role: 'USER',
          timestamp,
          content: 'retry me',
          status: 'ERROR',
        }),
      ]);

      const listener = vi.fn();
      list.addEventListener('yalo-chat-retry-message', listener);

      const user = list.shadowRoot!.querySelector('user-message')!;
      await (user as LitElement).updateComplete;
      const wrapper = user.shadowRoot!.querySelector(
        '.error-wrapper'
      ) as HTMLElement;
      wrapper.click();

      expect(listener).toHaveBeenCalledOnce();
      expect((listener.mock.calls[0][0] as CustomEvent).detail).toMatchObject({
        role: 'USER',
        type: 'text',
        content: 'retry me',
        status: 'ERROR',
      });
    });

    it('does not render error state when status is not ERROR', async () => {
      const list = await renderList([
        ChatMessage.text({
          id: 17,
          role: 'USER',
          timestamp,
          content: 'normal message',
          status: 'SENT',
        }),
      ]);

      const user = list.shadowRoot!.querySelector('user-message')!;
      await (user as LitElement).updateComplete;
      const wrapper = user.shadowRoot!.querySelector('.error-wrapper');
      expect(wrapper).toBeNull();

      const bubble = user.shadowRoot!.querySelector('.bubble');
      expect(bubble!.textContent).toContain('normal message');
    });
  });

  describe('product quantity updates', () => {
    it('renders the correct unit and subunit values on the product card', async () => {
      const list = await renderList([
        ChatMessage.product({
          id: 55,
          role: 'AGENT',
          timestamp,
          products: [
            buildProduct({
              sku: 'a',
              unitsAdded: 3,
              subunits: 6,
              subunitsAdded: 2,
              subunitName: '{amount, plural, one {bag} other {bags}}',
            }),
          ],
        }),
      ]);

      const card = await getProductCard(list);
      const inputs =
        card.shadowRoot!.querySelectorAll<LitElement>('numeric-input');
      expect(inputs).toHaveLength(2);

      const unitInput = inputs[0].shadowRoot!.querySelector('input')!;
      const subunitInput = inputs[1].shadowRoot!.querySelector('input')!;
      expect(unitInput.value).toContain('3');
      expect(subunitInput.value).toContain('2');
    });

    it('reflects updated quantities after re-rendering with new products', async () => {
      const list = await renderList([
        ChatMessage.product({
          id: 56,
          role: 'AGENT',
          timestamp,
          products: [buildProduct({ sku: 'a', unitsAdded: 1 })],
        }),
      ]);

      const cardBefore = await getProductCard(list);
      const inputBefore =
        cardBefore.shadowRoot!.querySelector('numeric-input') as LitElement;
      const valueBefore =
        inputBefore.shadowRoot!.querySelector('input')!.value;
      expect(valueBefore).toContain('1');

      // Simulate in-place update (same message id, different quantity)
      list.chatMessages = [
        ChatMessage.product({
          id: 56,
          role: 'AGENT',
          timestamp,
          products: [buildProduct({ sku: 'a', unitsAdded: 5 })],
        }),
      ];
      await list.updateComplete;

      const cardAfter = await getProductCard(list);
      const inputAfter =
        cardAfter.shadowRoot!.querySelector('numeric-input') as LitElement;
      await inputAfter.updateComplete;
      const valueAfter =
        inputAfter.shadowRoot!.querySelector('input')!.value;
      expect(valueAfter).toContain('5');
    });

    it('does not reset scroll when messages are updated in place', async () => {
      const products = [buildProduct({ sku: 'a', unitsAdded: 1 })];
      const list = await renderList([
        ChatMessage.product({
          id: 60,
          role: 'AGENT',
          timestamp,
          products,
        }),
      ]);

      const messageList = list.shadowRoot!.querySelector(
        '.message-list'
      ) as HTMLUListElement;

      // Simulate the user having scrolled up
      Object.defineProperty(messageList, 'scrollTop', {
        value: -600,
        writable: true,
      });

      // Update messages in place (same length array)
      const updatedProducts = [buildProduct({ sku: 'a', unitsAdded: 2 })];
      list.chatMessages = [
        ChatMessage.product({
          id: 60,
          role: 'AGENT',
          timestamp,
          products: updatedProducts,
        }),
      ];
      await list.updateComplete;

      expect(messageList.scrollTop).toBe(-600);
    });

    it('resets scroll when a new message is added', async () => {
      const list = await renderList([
        ChatMessage.text({
          id: 70,
          role: 'AGENT',
          timestamp,
          content: 'Hello',
        }),
      ]);

      const messageList = list.shadowRoot!.querySelector(
        '.message-list'
      ) as HTMLUListElement;

      // Simulate a small scroll offset (within threshold)
      Object.defineProperty(messageList, 'scrollTop', {
        value: -100,
        writable: true,
      });

      list.chatMessages = [
        ChatMessage.text({
          id: 71,
          role: 'USER',
          timestamp,
          content: 'New message',
        }),
        ...list.chatMessages,
      ];
      await list.updateComplete;

      expect(messageList.scrollTop).toBe(0);
    });
  });

  describe('product quantity commands', () => {
    it('clicking + emits a positive delta mapped to addToCart', async () => {
      const list = await renderList([
        ChatMessage.product({
          id: 60,
          role: 'AGENT',
          timestamp,
          products: [buildProduct({ sku: 'beer-sku', unitsAdded: 2 })],
        }),
      ]);

      const listener = vi.fn();
      list.addEventListener('yalo-chat-product-quantity-change', listener);

      const card = await getProductCard(list);
      const input =
        card.shadowRoot!.querySelector<LitElement>('numeric-input')!;
      await input.updateComplete;
      const buttons =
        input.shadowRoot!.querySelectorAll<HTMLButtonElement>('button');

      buttons[1].click(); // +

      const detail = (listener.mock.calls[0][0] as CustomEvent).detail;
      expect(detail).toMatchObject({
        sku: 'beer-sku',
        unitType: 'unit',
        value: 3,
      });
      // delta = 3 - 2 = 1 > 0 → addToCart
      expect(detail.value).toBeGreaterThan(2);
    });

    it('clicking - emits a negative delta mapped to removeFromCart', async () => {
      const list = await renderList([
        ChatMessage.product({
          id: 61,
          role: 'AGENT',
          timestamp,
          products: [buildProduct({ sku: 'beer-sku', unitsAdded: 3 })],
        }),
      ]);

      const listener = vi.fn();
      list.addEventListener('yalo-chat-product-quantity-change', listener);

      const card = await getProductCard(list);
      const input =
        card.shadowRoot!.querySelector<LitElement>('numeric-input')!;
      await input.updateComplete;
      const buttons =
        input.shadowRoot!.querySelectorAll<HTMLButtonElement>('button');

      buttons[0].click(); // -

      const detail = (listener.mock.calls[0][0] as CustomEvent).detail;
      expect(detail).toMatchObject({
        sku: 'beer-sku',
        unitType: 'unit',
        value: 2,
      });
      // delta = 2 - 3 = -1 < 0 → removeFromCart
      expect(detail.value).toBeLessThan(3);
    });

    it('clicking - at zero does not emit, resulting in no command', async () => {
      const list = await renderList([
        ChatMessage.product({
          id: 62,
          role: 'AGENT',
          timestamp,
          products: [buildProduct({ sku: 'beer-sku', unitsAdded: 0 })],
        }),
      ]);

      const listener = vi.fn();
      list.addEventListener('yalo-chat-product-quantity-change', listener);

      const card = await getProductCard(list);
      const input =
        card.shadowRoot!.querySelector<LitElement>('numeric-input')!;
      await input.updateComplete;
      const buttons =
        input.shadowRoot!.querySelectorAll<HTMLButtonElement>('button');

      buttons[0].click(); // -

      // No event emitted → delta = 0 → no command triggered
      expect(listener).not.toHaveBeenCalled();
    });

    it('clicking + on subunits emits a positive delta mapped to addToCart', async () => {
      const list = await renderList([
        ChatMessage.product({
          id: 63,
          role: 'AGENT',
          timestamp,
          products: [
            buildProduct({
              sku: 'beer-sku',
              unitsAdded: 1,
              subunits: 6,
              subunitsAdded: 2,
              subunitName: '{amount, plural, one {bottle} other {bottles}}',
            }),
          ],
        }),
      ]);

      const listener = vi.fn();
      list.addEventListener('yalo-chat-product-quantity-change', listener);

      const card = await getProductCard(list);
      const inputs =
        card.shadowRoot!.querySelectorAll<LitElement>('numeric-input');
      await inputs[1].updateComplete;
      const subunitButtons =
        inputs[1].shadowRoot!.querySelectorAll<HTMLButtonElement>('button');

      subunitButtons[1].click(); // + on subunits

      const detail = (listener.mock.calls[0][0] as CustomEvent).detail;
      expect(detail).toMatchObject({
        sku: 'beer-sku',
        unitType: 'subunit',
        value: 3,
      });
      // delta = 3 - 2 = 1 > 0 → addToCart
      expect(detail.value).toBeGreaterThan(2);
    });

    it('clicking - on subunits emits a negative delta mapped to removeFromCart', async () => {
      const list = await renderList([
        ChatMessage.product({
          id: 64,
          role: 'AGENT',
          timestamp,
          products: [
            buildProduct({
              sku: 'beer-sku',
              unitsAdded: 1,
              subunits: 6,
              subunitsAdded: 3,
              subunitName: '{amount, plural, one {bottle} other {bottles}}',
            }),
          ],
        }),
      ]);

      const listener = vi.fn();
      list.addEventListener('yalo-chat-product-quantity-change', listener);

      const card = await getProductCard(list);
      const inputs =
        card.shadowRoot!.querySelectorAll<LitElement>('numeric-input');
      await inputs[1].updateComplete;
      const subunitButtons =
        inputs[1].shadowRoot!.querySelectorAll<HTMLButtonElement>('button');

      subunitButtons[0].click(); // - on subunits

      const detail = (listener.mock.calls[0][0] as CustomEvent).detail;
      expect(detail).toMatchObject({
        sku: 'beer-sku',
        unitType: 'subunit',
        value: 2,
      });
      // delta = 2 - 3 = -1 < 0 → removeFromCart
      expect(detail.value).toBeLessThan(3);
    });
  });

  describe('buttons interaction', () => {
    it('dispatches yalo-chat-send-text-message with button text when clicked', async () => {
      const list = await renderList([
        ChatMessage.buttons({
          id: 30,
          role: 'AGENT',
          timestamp,
          buttons: ['Yes', 'No'],
          content: 'Pick one',
        }),
      ]);

      const listener = vi.fn();
      list.addEventListener('yalo-chat-send-text-message', listener);

      const assistant = list.shadowRoot!.querySelector('assistant-message')!;
      const buttonsMsg = assistant.shadowRoot!.querySelector('buttons-message')!;
      const buttons = buttonsMsg.shadowRoot!.querySelectorAll('button');
      expect(buttons).toHaveLength(2);

      buttons[0].click();

      expect(listener).toHaveBeenCalledOnce();
      const detail = (listener.mock.calls[0][0] as CustomEvent).detail;
      expect(detail).toMatchObject({
        role: 'USER',
        type: 'text',
        content: 'Yes',
      });
    });
  });

  describe('message routing', () => {
    it('renders AGENT messages as assistant-message and USER messages as user-message', async () => {
      const list = await renderList([
        ChatMessage.text({
          id: 20,
          role: 'AGENT',
          timestamp,
          content: 'agent msg',
        }),
        ChatMessage.text({
          id: 21,
          role: 'USER',
          timestamp,
          content: 'user msg',
        }),
      ]);

      const assistants =
        list.shadowRoot!.querySelectorAll('assistant-message');
      const users = list.shadowRoot!.querySelectorAll('user-message');
      expect(assistants).toHaveLength(1);
      expect(users).toHaveLength(1);
    });
  });
});
