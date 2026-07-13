// Copyright (c) Yalochat, Inc. All rights reserved.

import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { html, LitElement } from 'lit';
import { customElement } from 'lit/decorators.js';
import { ContextProvider } from '@lit/context';
import { yaloChatClientConfigContext } from '@domain/config/chat-config-context';
import type { YaloChatClientConfig } from '@domain/config/chat-config';
import {
  registeredCommandsContext,
  type RegisteredCommands,
} from '@domain/models/command/registered-commands-context';
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
  _commandsProvider = new ContextProvider(this, {
    context: registeredCommandsContext,
    initialValue: new Map() as RegisteredCommands,
  });

  render() {
    return html`<slot></slot>`;
  }
}

const registerGoToCart = (
  list: ChatMessageList,
  callback: () => void = () => {}
): void => {
  const wrapper = list.parentElement as TestContextProvider;
  wrapper._commandsProvider.setValue(new Map([['goToCart', callback]]));
};

// Flushes pending microtasks so async click handlers awaiting a completed
// promise get to update the component state before assertions run.
const settle = async (): Promise<void> => {
  await new Promise((resolve) => {
    setTimeout(resolve, 0);
  });
};

const renderList = async (messages: ChatMessage[]) => {
  const wrapper = document.createElement(
    'test-context-provider'
  ) as TestContextProvider;
  const list = document.createElement(
    'yalo-chat-message-list'
  ) as ChatMessageList;
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
    'yalo-chat-assistant-message'
  ) as LitElement;
  await assistant.updateComplete;
  const productMsg = assistant.shadowRoot!.querySelector(
    'yalo-chat-product-message'
  ) as LitElement;
  await productMsg.updateComplete;
  const card = productMsg.shadowRoot!.querySelector(
    'yalo-chat-product-card'
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

      const assistant = list.shadowRoot!.querySelector(
        'yalo-chat-assistant-message'
      );
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

      const assistant = list.shadowRoot!.querySelector(
        'yalo-chat-assistant-message'
      );
      const bubble = assistant!.shadowRoot!.querySelector('.voice-bubble');
      expect(bubble!.querySelector('yalo-chat-voice-message')).not.toBeNull();
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

      const assistant = list.shadowRoot!.querySelector(
        'yalo-chat-assistant-message'
      );
      const bubble = assistant!.shadowRoot!.querySelector('.image-bubble');
      expect(bubble!.querySelector('yalo-chat-image-message')).not.toBeNull();
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

      const assistant = list.shadowRoot!.querySelector(
        'yalo-chat-assistant-message'
      );
      const bubble = assistant!.shadowRoot!.querySelector('.video-bubble');
      expect(bubble!.querySelector('yalo-chat-video-message')).not.toBeNull();
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

      const assistant = list.shadowRoot!.querySelector(
        'yalo-chat-assistant-message'
      );
      const bubble = assistant!.shadowRoot!.querySelector('.attachment-bubble');
      expect(
        bubble!.querySelector('yalo-chat-attachment-message')
      ).not.toBeNull();
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

      const assistant = list.shadowRoot!.querySelector(
        'yalo-chat-assistant-message'
      );
      const productMsg = assistant!.shadowRoot!.querySelector(
        '.product-bubble yalo-chat-product-message'
      );
      expect(productMsg).not.toBeNull();
      expect(productMsg!.getAttribute('direction')).toBe('vertical');
      const cards = productMsg!.shadowRoot!.querySelectorAll(
        'yalo-chat-product-card'
      );
      expect(cards).toHaveLength(2);
      cards.forEach((card) => {
        expect((card as unknown as { layout: string }).layout).toBe(
          'horizontal'
        );
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

      const assistant = list.shadowRoot!.querySelector(
        'yalo-chat-assistant-message'
      );
      const productMsg = assistant!.shadowRoot!.querySelector(
        '.product-bubble yalo-chat-product-message'
      );
      expect(productMsg).not.toBeNull();
      expect(productMsg!.getAttribute('direction')).toBe('horizontal');
      const cards = productMsg!.shadowRoot!.querySelectorAll(
        'yalo-chat-product-card'
      );
      expect(cards).toHaveLength(2);
      cards.forEach((card) => {
        expect((card as unknown as { layout: string }).layout).toBe('vertical');
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
      const inputs = card.shadowRoot!.querySelectorAll(
        'yalo-chat-numeric-input'
      );
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
      const inputs = card.shadowRoot!.querySelectorAll(
        'yalo-chat-numeric-input'
      );
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
        card.shadowRoot!.querySelectorAll<LitElement>(
          'yalo-chat-numeric-input'
        );
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

      const assistant = list.shadowRoot!.querySelector(
        'yalo-chat-assistant-message'
      )!;
      const productMsg = assistant.shadowRoot!.querySelector(
        'yalo-chat-product-message'
      )!;
      const initialCards = productMsg.shadowRoot!.querySelectorAll(
        'yalo-chat-product-card'
      );
      const toggle = productMsg.shadowRoot!.querySelector(
        'button.expand'
      ) as HTMLButtonElement;

      expect(initialCards).toHaveLength(3);
      expect(toggle.textContent?.trim()).toBe('Show more');

      toggle.click();
      await (productMsg as LitElement).updateComplete;

      const expandedCards = productMsg.shadowRoot!.querySelectorAll(
        'yalo-chat-product-card'
      );
      const expandedToggle = productMsg.shadowRoot!.querySelector(
        'button.expand'
      ) as HTMLButtonElement;
      expect(expandedCards).toHaveLength(4);
      expect(expandedToggle.textContent?.trim()).toBe('Show less');
    });

    describe('product card cart button', () => {
      const getCartButton = async (
        list: ChatMessageList
      ): Promise<HTMLButtonElement> => {
        const card = await getProductCard(list);
        return card.shadowRoot!.querySelector<HTMLButtonElement>(
          '.cart-button'
        )!;
      };

      it('starts with "Add to cart" and no in-cart class when product.inCart is false', async () => {
        const list = await renderList([
          ChatMessage.product({
            id: 80,
            role: 'AGENT',
            timestamp,
            products: [buildProduct({ sku: 'a' })],
          }),
        ]);

        const button = await getCartButton(list);
        expect(button.textContent?.trim()).toBe('Add to cart');
        expect(button.classList.contains('in-cart')).toBe(false);
        expect(button.disabled).toBe(false);
      });

      it('starts in "In the cart" when the persisted product.inCart is true', async () => {
        const list = await renderList([
          ChatMessage.product({
            id: 81,
            role: 'AGENT',
            timestamp,
            products: [buildProduct({ sku: 'a', inCart: true })],
          }),
        ]);

        const button = await getCartButton(list);
        expect(button.textContent?.trim()).toContain('In the cart');
        expect(button.classList.contains('in-cart')).toBe(true);
        expect(button.disabled).toBe(true);
      });

      it('grays the button out while the cart update is pending and shows "In the cart" once it completes', async () => {
        let resolveCompleted!: (value: boolean) => void;
        const list = await renderList([
          ChatMessage.product({
            id: 82,
            role: 'AGENT',
            timestamp,
            products: [buildProduct({ sku: 'a' })],
          }),
        ]);
        list.addEventListener('yalo-chat-product-add-to-cart', (e) => {
          (e as CustomEvent).detail.completed = new Promise<boolean>(
            (resolve) => {
              resolveCompleted = resolve;
            }
          );
        });

        const button = await getCartButton(list);
        button.click();
        const card = await getProductCard(list);
        await card.updateComplete;

        const loadingButton =
          card.shadowRoot!.querySelector<HTMLButtonElement>('.cart-button')!;
        expect(loadingButton.textContent?.trim()).toBe('Add to cart');
        expect(loadingButton.classList.contains('loading')).toBe(true);
        expect(loadingButton.disabled).toBe(true);

        list.chatMessages = [
          ChatMessage.product({
            id: 82,
            role: 'AGENT',
            timestamp,
            products: [buildProduct({ sku: 'a', inCart: true })],
          }),
        ];
        resolveCompleted(true);
        await settle();
        await list.updateComplete;
        const updatedCard = await getProductCard(list);
        await updatedCard.updateComplete;

        const refreshed =
          updatedCard.shadowRoot!.querySelector<HTMLButtonElement>(
            '.cart-button'
          )!;
        expect(refreshed.textContent?.trim()).toContain('In the cart');
        expect(refreshed.classList.contains('in-cart')).toBe(true);
        expect(refreshed.classList.contains('loading')).toBe(false);
        expect(refreshed.querySelector('.icon')).not.toBeNull();
      });

      it('returns the button to "Add to cart" when the cart update fails', async () => {
        let resolveCompleted!: (value: boolean) => void;
        const list = await renderList([
          ChatMessage.product({
            id: 87,
            role: 'AGENT',
            timestamp,
            products: [buildProduct({ sku: 'a' })],
          }),
        ]);
        list.addEventListener('yalo-chat-product-add-to-cart', (e) => {
          (e as CustomEvent).detail.completed = new Promise<boolean>(
            (resolve) => {
              resolveCompleted = resolve;
            }
          );
        });

        const button = await getCartButton(list);
        button.click();
        const card = await getProductCard(list);
        await card.updateComplete;
        expect(button.classList.contains('loading')).toBe(true);

        resolveCompleted(false);
        await settle();
        await card.updateComplete;

        const refreshed =
          card.shadowRoot!.querySelector<HTMLButtonElement>('.cart-button')!;
        expect(refreshed.textContent?.trim()).toBe('Add to cart');
        expect(refreshed.classList.contains('loading')).toBe(false);
        expect(refreshed.disabled).toBe(false);
      });

      it('dispatches yalo-chat-product-add-to-cart with messageId and sku on click', async () => {
        const list = await renderList([
          ChatMessage.product({
            id: 83,
            role: 'AGENT',
            timestamp,
            products: [buildProduct({ sku: 'sku-xyz' })],
          }),
        ]);

        const listener = vi.fn();
        list.addEventListener('yalo-chat-product-add-to-cart', listener);

        const button = await getCartButton(list);
        button.click();

        expect(listener).toHaveBeenCalledOnce();
        const detail = (listener.mock.calls[0][0] as CustomEvent).detail;
        expect(detail).toMatchObject({ messageId: 83, sku: 'sku-xyz' });
      });

      it('shows "Update the cart" when the quantity changes after being added', async () => {
        const list = await renderList([
          ChatMessage.product({
            id: 84,
            role: 'AGENT',
            timestamp,
            products: [buildProduct({ sku: 'a', unitsAdded: 1, inCart: true })],
          }),
        ]);

        list.chatMessages = [
          ChatMessage.product({
            id: 84,
            role: 'AGENT',
            timestamp,
            products: [buildProduct({ sku: 'a', unitsAdded: 2, inCart: true })],
          }),
        ];
        await list.updateComplete;
        const updatedCard = await getProductCard(list);
        await updatedCard.updateComplete;

        const updatedButton =
          updatedCard.shadowRoot!.querySelector<HTMLButtonElement>(
            '.cart-button'
          )!;
        expect(updatedButton.textContent?.trim()).toBe('Update the cart');
        expect(updatedButton.classList.contains('in-cart')).toBe(false);
        expect(updatedButton.disabled).toBe(false);
      });

      it('resets to "Add to cart" when the same card position renders a different sku', async () => {
        const list = await renderList([
          ChatMessage.product({
            id: 86,
            role: 'AGENT',
            timestamp,
            products: [buildProduct({ sku: 'a' })],
          }),
        ]);

        const initialButton = (
          await getProductCard(list)
        ).shadowRoot!.querySelector<HTMLButtonElement>('.cart-button')!;
        initialButton.click();
        await (
          await getProductCard(list)
        ).updateComplete;

        list.chatMessages = [
          ChatMessage.product({
            id: 86,
            role: 'AGENT',
            timestamp,
            products: [buildProduct({ sku: 'b' })],
          }),
        ];
        await list.updateComplete;

        const card = await getProductCard(list);
        await card.updateComplete;
        const button =
          card.shadowRoot!.querySelector<HTMLButtonElement>('.cart-button')!;
        expect(button.textContent?.trim()).toBe('Add to cart');
        expect(button.classList.contains('in-cart')).toBe(false);
      });

      it('returns to "In the cart" after clicking "Update the cart"', async () => {
        const list = await renderList([
          ChatMessage.product({
            id: 85,
            role: 'AGENT',
            timestamp,
            products: [buildProduct({ sku: 'a', unitsAdded: 1, inCart: true })],
          }),
        ]);

        list.chatMessages = [
          ChatMessage.product({
            id: 85,
            role: 'AGENT',
            timestamp,
            products: [buildProduct({ sku: 'a', unitsAdded: 3, inCart: true })],
          }),
        ];
        await list.updateComplete;

        const card = await getProductCard(list);
        await card.updateComplete;
        const button =
          card.shadowRoot!.querySelector<HTMLButtonElement>('.cart-button')!;
        expect(button.textContent?.trim()).toBe('Update the cart');

        let resolveCompleted!: (value: boolean) => void;
        list.addEventListener('yalo-chat-product-add-to-cart', (e) => {
          (e as CustomEvent).detail.completed = new Promise<boolean>(
            (resolve) => {
              resolveCompleted = resolve;
            }
          );
        });

        button.click();
        await card.updateComplete;
        const pendingButton =
          card.shadowRoot!.querySelector<HTMLButtonElement>('.cart-button')!;
        expect(pendingButton.textContent?.trim()).toBe('Update the cart');
        expect(pendingButton.classList.contains('loading')).toBe(true);
        expect(pendingButton.disabled).toBe(true);

        resolveCompleted(true);
        await settle();
        await card.updateComplete;
        const finalButton =
          card.shadowRoot!.querySelector<HTMLButtonElement>('.cart-button')!;
        expect(finalButton.textContent?.trim()).toContain('In the cart');
        expect(finalButton.classList.contains('in-cart')).toBe(true);
        expect(finalButton.classList.contains('loading')).toBe(false);
      });
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

      const assistant = list.shadowRoot!.querySelector(
        'yalo-chat-assistant-message'
      );
      const p = assistant!.shadowRoot!.querySelector('p');
      expect(p!.textContent).toContain('fallback');
    });

    it('renders header when present', async () => {
      const list = await renderList([
        new ChatMessage({
          id: 70,
          role: 'AGENT',
          type: 'text',
          timestamp,
          content: 'Body',
          header: 'Greetings',
        }),
      ]);

      const assistant = list.shadowRoot!.querySelector(
        'yalo-chat-assistant-message'
      )!;
      const header = assistant.shadowRoot!.querySelector('.header');
      expect(header!.textContent).toContain('Greetings');
    });

    it('renders footer when present', async () => {
      const list = await renderList([
        new ChatMessage({
          id: 71,
          role: 'AGENT',
          type: 'text',
          timestamp,
          content: 'Body',
          footer: 'Powered by Yalo',
        }),
      ]);

      const assistant = list.shadowRoot!.querySelector(
        'yalo-chat-assistant-message'
      )!;
      const footer = assistant.shadowRoot!.querySelector('.footer');
      expect(footer!.textContent).toContain('Powered by Yalo');
    });

    it('omits header and footer when absent', async () => {
      const list = await renderList([
        ChatMessage.text({
          id: 72,
          role: 'AGENT',
          timestamp,
          content: 'Just body',
        }),
      ]);

      const assistant = list.shadowRoot!.querySelector(
        'yalo-chat-assistant-message'
      )!;
      expect(assistant.shadowRoot!.querySelector('.header')).toBeNull();
      expect(assistant.shadowRoot!.querySelector('.footer')).toBeNull();
    });

    it('renders only non-reply buttons inline regardless of whether the agent message is the latest', async () => {
      const list = await renderList([
        ChatMessage.text({
          id: 100,
          role: 'USER',
          timestamp,
          content: 'follow up',
        }),
        new ChatMessage({
          id: 73,
          role: 'AGENT',
          type: 'text',
          timestamp,
          content: 'Pick one',
          buttons: [
            { text: 'Yes', type: 'reply' },
            { text: 'No', type: 'postback' },
            { text: 'Maybe', type: 'reply' },
          ],
        }),
      ]);

      const assistant = list.shadowRoot!.querySelector(
        'yalo-chat-assistant-message'
      )!;
      const buttons = assistant.shadowRoot!.querySelectorAll('.buttons button');
      expect(buttons).toHaveLength(1);
      expect(buttons[0].textContent?.trim()).toBe('No');
    });

    it('hides reply buttons inline on the latest agent message and renders only non-reply buttons', async () => {
      const list = await renderList([
        new ChatMessage({
          id: 173,
          role: 'AGENT',
          type: 'text',
          timestamp,
          content: 'Pick one',
          buttons: [
            { text: 'Yes', type: 'reply' },
            { text: 'No', type: 'postback' },
            { text: 'Maybe', type: 'reply' },
          ],
        }),
      ]);

      const assistant = list.shadowRoot!.querySelector(
        'yalo-chat-assistant-message'
      )!;
      const buttons = assistant.shadowRoot!.querySelectorAll('.buttons button');
      expect(buttons).toHaveLength(1);
      expect(buttons[0].textContent?.trim()).toBe('No');
    });

    it('renders link buttons as anchor tags pointing to the url', async () => {
      const list = await renderList([
        new ChatMessage({
          id: 76,
          role: 'AGENT',
          type: 'text',
          timestamp,
          content: 'Visit our site',
          buttons: [{ text: 'Open', type: 'link', url: 'https://example.com' }],
        }),
      ]);

      const assistant = list.shadowRoot!.querySelector(
        'yalo-chat-assistant-message'
      )!;
      const anchors =
        assistant.shadowRoot!.querySelectorAll<HTMLAnchorElement>('.buttons a');
      expect(anchors).toHaveLength(1);
      expect(anchors[0]).toMatchObject({
        href: 'https://example.com/',
        target: '_blank',
        rel: 'noopener noreferrer',
      });
      expect(anchors[0].textContent).toContain('Open');
    });

    it('renders link buttons as a regular button when the url is missing', async () => {
      const list = await renderList([
        new ChatMessage({
          id: 77,
          role: 'AGENT',
          type: 'text',
          timestamp,
          content: 'Broken link',
          buttons: [{ text: 'No url', type: 'link' }],
        }),
      ]);

      const assistant = list.shadowRoot!.querySelector(
        'yalo-chat-assistant-message'
      )!;
      expect(assistant.shadowRoot!.querySelector('.buttons a')).toBeNull();
      expect(
        assistant.shadowRoot!.querySelector('.buttons button')!.textContent
      ).toContain('No url');
    });

    it('omits the buttons container when there are no buttons', async () => {
      const list = await renderList([
        ChatMessage.text({
          id: 74,
          role: 'AGENT',
          timestamp,
          content: 'No buttons',
        }),
      ]);

      const assistant = list.shadowRoot!.querySelector(
        'yalo-chat-assistant-message'
      )!;
      expect(assistant.shadowRoot!.querySelector('.buttons')).toBeNull();
    });

    it('removes the quick replies after one is selected, leaving only the user message text', async () => {
      const agent = new ChatMessage({
        id: 75,
        role: 'AGENT',
        type: 'text',
        timestamp,
        content: 'Pick one',
        buttons: [
          { text: 'Yes', type: 'reply' },
          { text: 'No', type: 'reply' },
        ],
      });
      const list = await renderList([agent]);

      const quickReplies = list.shadowRoot!.querySelector(
        'yalo-chat-quick-replies'
      )!;
      await (quickReplies as LitElement).updateComplete;
      const chips =
        quickReplies.shadowRoot!.querySelectorAll<HTMLButtonElement>(
          '.chips button'
        );
      expect([...chips].map((c) => c.textContent?.trim())).toEqual([
        'Yes',
        'No',
      ]);

      const listener = vi.fn();
      list.addEventListener('yalo-chat-send-text-message', listener);
      chips[0].click();

      expect(listener).toHaveBeenCalledOnce();
      expect((listener.mock.calls[0][0] as CustomEvent).detail).toMatchObject({
        role: 'USER',
        type: 'text',
        content: 'Yes',
      });

      list.chatMessages = [
        ChatMessage.text({
          id: 76,
          role: 'USER',
          timestamp,
          content: 'Yes',
        }),
        agent,
      ];
      await list.updateComplete;
      await (quickReplies as LitElement).updateComplete;

      expect(
        quickReplies.shadowRoot!.querySelectorAll('.chips button')
      ).toHaveLength(0);
      const assistant = list.shadowRoot!.querySelector(
        'yalo-chat-assistant-message'
      )!;
      await (assistant as LitElement).updateComplete;
      expect(
        assistant.shadowRoot!.querySelectorAll('.buttons button')
      ).toHaveLength(0);
      const user = list.shadowRoot!.querySelector('yalo-chat-user-message')!;
      await (user as LitElement).updateComplete;
      expect(user.shadowRoot!.textContent).toContain('Yes');
    });
  });

  describe('product confirmation messages', () => {
    const confirmation = (
      overrides: Partial<ConstructorParameters<typeof ChatMessage>[0]> = {}
    ) =>
      ChatMessage.productConfirmation({
        id: 300,
        role: 'AGENT',
        timestamp,
        header: 'Added to cart',
        content: 'You have 3 bags',
        footer: 'Continue shopping',
        button: { text: 'Done', type: 'reply' },
        product: buildProduct({ sku: 'sku-1', unitsAdded: 3 }),
        ...overrides,
      });

    const getCard = async (list: ChatMessageList) => {
      const assistant = list.shadowRoot!.querySelector(
        'yalo-chat-assistant-message'
      ) as LitElement;
      await assistant.updateComplete;
      const card = assistant.shadowRoot!.querySelector(
        'yalo-chat-product-confirmation-message'
      ) as LitElement;
      await card.updateComplete;
      return card;
    };

    it('renders header, body, and button inside the confirmation card', async () => {
      const list = await renderList([confirmation()]);
      const card = await getCard(list);

      expect(card.shadowRoot!.querySelector('.title')!.textContent).toContain(
        'Added to cart'
      );
      expect(card.shadowRoot!.querySelector('.body')!.textContent).toContain(
        'You have 3 bags'
      );
      expect(card.shadowRoot!.querySelector('.button')!.textContent).toContain(
        'Done'
      );
      expect(card.shadowRoot!.querySelector('.footer')).toBeNull();
    });

    it('grays the button out while the confirmation is pending and marks it clicked once it completes', async () => {
      let resolveCompleted!: (value: boolean) => void;
      const list = await renderList([confirmation()]);
      list.addEventListener('yalo-chat-product-confirmation-clicked', (e) => {
        (e as CustomEvent).detail.completed = new Promise<boolean>(
          (resolve) => {
            resolveCompleted = resolve;
          }
        );
      });
      const card = await getCard(list);

      const button =
        card.shadowRoot!.querySelector<HTMLButtonElement>('.button')!;
      expect(button.classList.contains('clicked')).toBe(false);

      button.click();
      await card.updateComplete;

      expect(button.classList.contains('loading')).toBe(true);
      expect(button.classList.contains('clicked')).toBe(false);
      expect(button.disabled).toBe(true);

      list.chatMessages = [confirmation({ status: 'CLICKED' })];
      resolveCompleted(true);
      await settle();
      await list.updateComplete;
      const updatedCard = await getCard(list);

      const updatedButton =
        updatedCard.shadowRoot!.querySelector<HTMLButtonElement>('.button')!;
      expect(updatedButton.classList.contains('clicked')).toBe(true);
      expect(updatedButton.classList.contains('loading')).toBe(false);
      expect(updatedButton.disabled).toBe(true);
    });

    it('re-enables the button when the confirmation fails', async () => {
      let resolveCompleted!: (value: boolean) => void;
      const list = await renderList([confirmation()]);
      list.addEventListener('yalo-chat-product-confirmation-clicked', (e) => {
        (e as CustomEvent).detail.completed = new Promise<boolean>(
          (resolve) => {
            resolveCompleted = resolve;
          }
        );
      });
      const card = await getCard(list);

      const button =
        card.shadowRoot!.querySelector<HTMLButtonElement>('.button')!;
      button.click();
      await card.updateComplete;
      expect(button.classList.contains('loading')).toBe(true);

      resolveCompleted(false);
      await settle();
      await card.updateComplete;

      expect(button.classList.contains('loading')).toBe(false);
      expect(button.classList.contains('clicked')).toBe(false);
      expect(button.disabled).toBe(false);
    });

    it('dispatches yalo-chat-product-confirmation-clicked with the message on button click', async () => {
      const message = confirmation({ id: 305 });
      const list = await renderList([message]);
      const card = await getCard(list);

      const listener = vi.fn();
      list.addEventListener('yalo-chat-product-confirmation-clicked', listener);

      card.shadowRoot!.querySelector<HTMLButtonElement>('.button')!.click();

      expect(listener).toHaveBeenCalledOnce();
      const detail = (listener.mock.calls[0][0] as CustomEvent).detail;
      expect(detail).toMatchObject({
        message: {
          id: 305,
          type: 'productConfirmation',
        },
      });
    });

    it('renders the button as clicked when the message status is CLICKED', async () => {
      const list = await renderList([confirmation({ status: 'CLICKED' })]);
      const card = await getCard(list);
      const button =
        card.shadowRoot!.querySelector<HTMLButtonElement>('.button')!;

      expect(button.classList.contains('clicked')).toBe(true);
      expect(button.disabled).toBe(true);
    });

    it('keeps the button text and never shows Go to cart once clicked', async () => {
      const list = await renderList([confirmation({ status: 'CLICKED' })]);
      registerGoToCart(list);
      const card = await getCard(list);

      const button =
        card.shadowRoot!.querySelector<HTMLButtonElement>('.button')!;
      expect(button.textContent).toContain('Done');
      expect(button.textContent).not.toContain('Go to cart');
      expect(button.disabled).toBe(true);
      expect(button.classList.contains('clicked')).toBe(true);
    });

    it('does not render the footer before the confirmation is clicked', async () => {
      const list = await renderList([confirmation()]);
      registerGoToCart(list);
      const card = await getCard(list);

      expect(card.shadowRoot!.querySelector('.footer')).toBeNull();
    });

    it('does not render the footer when clicked without a goToCart command', async () => {
      const list = await renderList([confirmation({ status: 'CLICKED' })]);
      const card = await getCard(list);

      expect(card.shadowRoot!.querySelector('.footer')).toBeNull();
    });

    it('does not render the footer when it is empty even if goToCart is registered', async () => {
      const list = await renderList([
        confirmation({ status: 'CLICKED', footer: '   ' }),
      ]);
      registerGoToCart(list);
      const card = await getCard(list);

      expect(card.shadowRoot!.querySelector('.footer')).toBeNull();
    });

    it('reveals the footer once the confirmation is clicked and goToCart is registered', async () => {
      const list = await renderList([confirmation({ status: 'CLICKED' })]);
      registerGoToCart(list);
      const card = await getCard(list);

      const footer = card.shadowRoot!.querySelector('.footer');
      expect(footer!.textContent).toContain('Continue shopping');
    });

    it('reveals the footer after the confirmation completes when goToCart is registered', async () => {
      let resolveCompleted!: (value: boolean) => void;
      const list = await renderList([confirmation()]);
      registerGoToCart(list);
      list.addEventListener('yalo-chat-product-confirmation-clicked', (e) => {
        (e as CustomEvent).detail.completed = new Promise<boolean>(
          (resolve) => {
            resolveCompleted = resolve;
          }
        );
      });
      const card = await getCard(list);
      expect(card.shadowRoot!.querySelector('.footer')).toBeNull();

      card.shadowRoot!.querySelector<HTMLButtonElement>('.button')!.click();
      await card.updateComplete;

      list.chatMessages = [confirmation({ status: 'CLICKED' })];
      resolveCompleted(true);
      await settle();
      await list.updateComplete;
      const updatedCard = await getCard(list);

      expect(
        updatedCard.shadowRoot!.querySelector('.footer')!.textContent
      ).toContain('Continue shopping');
    });

    it('dispatches yalo-chat-go-to-cart when the footer is clicked', async () => {
      const list = await renderList([confirmation({ status: 'CLICKED' })]);
      registerGoToCart(list);
      const card = await getCard(list);

      const goToCartListener = vi.fn();
      const confirmationListener = vi.fn();
      const sendTextListener = vi.fn();
      list.addEventListener('yalo-chat-go-to-cart', goToCartListener);
      list.addEventListener(
        'yalo-chat-product-confirmation-clicked',
        confirmationListener
      );
      list.addEventListener('yalo-chat-send-text-message', sendTextListener);

      card.shadowRoot!.querySelector<HTMLButtonElement>('.footer')!.click();

      expect(goToCartListener).toHaveBeenCalledOnce();
      expect(confirmationListener).not.toHaveBeenCalled();
      expect(sendTextListener).not.toHaveBeenCalled();
    });

    it('does not render the outer assistant-message header, footer, or buttons', async () => {
      const list = await renderList([confirmation()]);
      const assistant = list.shadowRoot!.querySelector(
        'yalo-chat-assistant-message'
      ) as LitElement;
      await assistant.updateComplete;

      expect(assistant.shadowRoot!.querySelector('.header')).toBeNull();
      expect(assistant.shadowRoot!.querySelector('.footer')).toBeNull();
      expect(assistant.shadowRoot!.querySelector('.buttons')).toBeNull();
    });
  });

  describe('quick replies', () => {
    it('renders quick replies from the latest agent message in the emerging section', async () => {
      const list = await renderList([
        new ChatMessage({
          id: 200,
          role: 'AGENT',
          type: 'text',
          timestamp,
          content: 'Pick one',
          buttons: [
            { text: 'Yes', type: 'reply' },
            { text: 'Cancel', type: 'postback' },
            { text: 'Maybe', type: 'reply' },
          ],
        }),
      ]);

      const quickReplies = list.shadowRoot!.querySelector(
        'yalo-chat-quick-replies'
      );
      expect(quickReplies).not.toBeNull();
      await (quickReplies as LitElement).updateComplete;

      const chips =
        quickReplies!.shadowRoot!.querySelectorAll<HTMLButtonElement>(
          '.chips button'
        );
      expect(chips).toHaveLength(2);
      expect([...chips].map((c) => c.textContent?.trim())).toEqual([
        'Yes',
        'Maybe',
      ]);
    });

    it('does not render quick replies for a product confirmation call to action', async () => {
      const list = await renderList([
        ChatMessage.productConfirmation({
          id: 250,
          role: 'AGENT',
          timestamp,
          content: 'You have 3 bags',
          header: 'Added to cart',
          footer: 'Tap to undo',
          button: { text: 'Continue' },
          product: new Product({
            sku: 'SKU-1',
            name: '',
            price: 0,
            unitName: '',
          }),
        }),
      ]);

      const quickReplies = list.shadowRoot!.querySelector(
        'yalo-chat-quick-replies'
      );
      await (quickReplies as LitElement).updateComplete;
      const container = quickReplies!.shadowRoot!.querySelector('.container');
      expect(container?.classList.contains('open')).toBe(false);
    });

    it('keeps the emerging section closed when there are no reply buttons in the latest message', async () => {
      const list = await renderList([
        ChatMessage.text({
          id: 201,
          role: 'AGENT',
          timestamp,
          content: 'Plain text',
        }),
      ]);

      const quickReplies = list.shadowRoot!.querySelector(
        'yalo-chat-quick-replies'
      );
      await (quickReplies as LitElement).updateComplete;
      const container = quickReplies!.shadowRoot!.querySelector('.container');
      expect(container?.classList.contains('open')).toBe(false);
    });

    it('closes the emerging section when the latest message becomes a user message', async () => {
      const agent = new ChatMessage({
        id: 202,
        role: 'AGENT',
        type: 'text',
        timestamp,
        content: 'Pick one',
        buttons: [{ text: 'Yes', type: 'reply' }],
      });
      const list = await renderList([agent]);

      const quickReplies = list.shadowRoot!.querySelector(
        'yalo-chat-quick-replies'
      );
      await (quickReplies as LitElement).updateComplete;
      expect(
        quickReplies!.shadowRoot!.querySelector('.container.open')
      ).not.toBeNull();

      list.chatMessages = [
        ChatMessage.text({
          id: 203,
          role: 'USER',
          timestamp,
          content: 'Yes',
        }),
        agent,
      ];
      await list.updateComplete;
      await (quickReplies as LitElement).updateComplete;

      expect(
        quickReplies!.shadowRoot!.querySelector('.container.open')
      ).toBeNull();
    });

    it('hides previous agent quick replies once a newer message arrives', async () => {
      const agent = new ChatMessage({
        id: 204,
        role: 'AGENT',
        type: 'text',
        timestamp,
        content: 'Pick one',
        buttons: [
          { text: 'Yes', type: 'reply' },
          { text: 'No', type: 'reply' },
          { text: 'Open link', type: 'link', url: 'https://example.com' },
        ],
      });
      const list = await renderList([agent]);

      list.chatMessages = [
        ChatMessage.text({
          id: 205,
          role: 'USER',
          timestamp,
          content: 'Yes',
        }),
        agent,
      ];
      await list.updateComplete;

      const assistant = list.shadowRoot!.querySelector(
        'yalo-chat-assistant-message'
      )!;
      await (assistant as LitElement).updateComplete;
      const replyButtons =
        assistant.shadowRoot!.querySelectorAll('.buttons button');
      expect(replyButtons).toHaveLength(0);
      const links = assistant.shadowRoot!.querySelectorAll('.buttons a');
      expect(links).toHaveLength(1);
    });

    it('keeps quick replies visible when a newer agent message without replies arrives', async () => {
      const agent = new ChatMessage({
        id: 210,
        role: 'AGENT',
        type: 'text',
        timestamp,
        content: 'Pick one',
        buttons: [
          { text: 'Yes', type: 'reply' },
          { text: 'No', type: 'reply' },
        ],
      });
      const list = await renderList([agent]);

      list.chatMessages = [
        ChatMessage.text({
          id: 211,
          role: 'AGENT',
          timestamp,
          content: 'Any time now',
        }),
        agent,
      ];
      await list.updateComplete;

      const quickReplies = list.shadowRoot!.querySelector(
        'yalo-chat-quick-replies'
      );
      await (quickReplies as LitElement).updateComplete;

      const chips =
        quickReplies!.shadowRoot!.querySelectorAll<HTMLButtonElement>(
          '.chips button'
        );
      expect([...chips].map((c) => c.textContent?.trim())).toEqual([
        'Yes',
        'No',
      ]);
    });

    it('overrides quick replies with those of a newer agent message', async () => {
      const agent = new ChatMessage({
        id: 212,
        role: 'AGENT',
        type: 'text',
        timestamp,
        content: 'Pick one',
        buttons: [{ text: 'Yes', type: 'reply' }],
      });
      const list = await renderList([agent]);

      list.chatMessages = [
        new ChatMessage({
          id: 213,
          role: 'AGENT',
          type: 'text',
          timestamp,
          content: 'Pick again',
          buttons: [{ text: 'Later', type: 'reply' }],
        }),
        agent,
      ];
      await list.updateComplete;

      const quickReplies = list.shadowRoot!.querySelector(
        'yalo-chat-quick-replies'
      );
      await (quickReplies as LitElement).updateComplete;

      const chips =
        quickReplies!.shadowRoot!.querySelectorAll<HTMLButtonElement>(
          '.chips button'
        );
      expect([...chips].map((c) => c.textContent?.trim())).toEqual(['Later']);
    });

    it('dispatches yalo-chat-send-text-message when a quick reply chip is clicked', async () => {
      const list = await renderList([
        new ChatMessage({
          id: 206,
          role: 'AGENT',
          type: 'text',
          timestamp,
          content: 'Pick one',
          buttons: [{ text: 'Yes', type: 'reply' }],
        }),
      ]);

      const listener = vi.fn();
      list.addEventListener('yalo-chat-send-text-message', listener);

      const quickReplies = list.shadowRoot!.querySelector(
        'yalo-chat-quick-replies'
      );
      await (quickReplies as LitElement).updateComplete;
      const chip =
        quickReplies!.shadowRoot!.querySelector<HTMLButtonElement>(
          '.chips button'
        )!;
      chip.click();

      expect(listener).toHaveBeenCalledOnce();
      expect((listener.mock.calls[0][0] as CustomEvent).detail).toMatchObject({
        role: 'USER',
        type: 'text',
        content: 'Yes',
      });
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

      const user = list.shadowRoot!.querySelector('yalo-chat-user-message');
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

      const user = list.shadowRoot!.querySelector('yalo-chat-user-message');
      const bubble = user!.shadowRoot!.querySelector('.voice-bubble');
      expect(bubble!.querySelector('yalo-chat-voice-message')).not.toBeNull();
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

      const user = list.shadowRoot!.querySelector('yalo-chat-user-message');
      const bubble = user!.shadowRoot!.querySelector('.image-bubble');
      expect(bubble!.querySelector('yalo-chat-image-message')).not.toBeNull();
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

      const user = list.shadowRoot!.querySelector('yalo-chat-user-message');
      const bubble = user!.shadowRoot!.querySelector('.bubble');
      expect(
        bubble!.querySelector('yalo-chat-attachment-message')
      ).not.toBeNull();
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

      const user = list.shadowRoot!.querySelector('yalo-chat-user-message');
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

      const user = list.shadowRoot!.querySelector('yalo-chat-user-message')!;
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

      const user = list.shadowRoot!.querySelector('yalo-chat-user-message')!;
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

      const user = list.shadowRoot!.querySelector('yalo-chat-user-message')!;
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
      const inputs = card.shadowRoot!.querySelectorAll<LitElement>(
        'yalo-chat-numeric-input'
      );
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
      const inputBefore = cardBefore.shadowRoot!.querySelector(
        'yalo-chat-numeric-input'
      ) as LitElement;
      const valueBefore = inputBefore.shadowRoot!.querySelector('input')!.value;
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
      const inputAfter = cardAfter.shadowRoot!.querySelector(
        'yalo-chat-numeric-input'
      ) as LitElement;
      await inputAfter.updateComplete;
      const valueAfter = inputAfter.shadowRoot!.querySelector('input')!.value;
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

  describe('product quantity events', () => {
    it('clicking + emits yalo-chat-product-quantity-change with the new unit value', async () => {
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
      const input = card.shadowRoot!.querySelector<LitElement>(
        'yalo-chat-numeric-input'
      )!;
      await input.updateComplete;
      const buttons =
        input.shadowRoot!.querySelectorAll<HTMLButtonElement>('button');

      buttons[1].click();

      expect((listener.mock.calls[0][0] as CustomEvent).detail).toMatchObject({
        sku: 'beer-sku',
        unitType: 'unit',
        value: 3,
      });
    });

    it('clicking - emits yalo-chat-product-quantity-change with the new unit value', async () => {
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
      const input = card.shadowRoot!.querySelector<LitElement>(
        'yalo-chat-numeric-input'
      )!;
      await input.updateComplete;
      const buttons =
        input.shadowRoot!.querySelectorAll<HTMLButtonElement>('button');

      buttons[0].click();

      expect((listener.mock.calls[0][0] as CustomEvent).detail).toMatchObject({
        sku: 'beer-sku',
        unitType: 'unit',
        value: 2,
      });
    });

    it('clicking - at zero does not emit a quantity change', async () => {
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
      const input = card.shadowRoot!.querySelector<LitElement>(
        'yalo-chat-numeric-input'
      )!;
      await input.updateComplete;
      const buttons =
        input.shadowRoot!.querySelectorAll<HTMLButtonElement>('button');

      buttons[0].click();

      expect(listener).not.toHaveBeenCalled();
    });

    it('clicking + on subunits emits yalo-chat-product-quantity-change with the new subunit value', async () => {
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
      const inputs = card.shadowRoot!.querySelectorAll<LitElement>(
        'yalo-chat-numeric-input'
      );
      await inputs[1].updateComplete;
      const subunitButtons =
        inputs[1].shadowRoot!.querySelectorAll<HTMLButtonElement>('button');

      subunitButtons[1].click();

      expect((listener.mock.calls[0][0] as CustomEvent).detail).toMatchObject({
        sku: 'beer-sku',
        unitType: 'subunit',
        value: 3,
      });
    });

    it('clicking - on subunits emits yalo-chat-product-quantity-change with the new subunit value', async () => {
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
      const inputs = card.shadowRoot!.querySelectorAll<LitElement>(
        'yalo-chat-numeric-input'
      );
      await inputs[1].updateComplete;
      const subunitButtons =
        inputs[1].shadowRoot!.querySelectorAll<HTMLButtonElement>('button');

      subunitButtons[0].click();

      expect((listener.mock.calls[0][0] as CustomEvent).detail).toMatchObject({
        sku: 'beer-sku',
        unitType: 'subunit',
        value: 2,
      });
    });
  });

  describe('voice playback', () => {
    class FakeAudio extends EventTarget {
      src: string;
      play = vi.fn(() => Promise.resolve());
      pause = vi.fn();
      constructor(src: string) {
        super();
        this.src = src;
        audioInstances.push(this);
      }
    }

    let audioInstances: FakeAudio[] = [];

    beforeEach(() => {
      audioInstances = [];
      vi.stubGlobal('Audio', FakeAudio);
      vi.stubGlobal('URL', {
        createObjectURL: vi.fn(() => 'blob:fake-url'),
        revokeObjectURL: vi.fn(),
      });
    });

    afterEach(() => {
      vi.unstubAllGlobals();
    });

    const getVoiceMessage = async (
      list: ChatMessageList
    ): Promise<LitElement> => {
      const host = list.shadowRoot!.querySelector(
        'yalo-chat-assistant-message, yalo-chat-user-message'
      ) as LitElement;
      await host.updateComplete;
      const voice = host.shadowRoot!.querySelector(
        'yalo-chat-voice-message'
      ) as LitElement;
      await voice.updateComplete;
      return voice;
    };

    const getPlayButton = (voice: LitElement): HTMLButtonElement =>
      voice.shadowRoot!.querySelector('.play-button') as HTMLButtonElement;

    const getPlayButtonIcon = (voice: LitElement): string | null =>
      getPlayButton(voice)
        .querySelector('.yalo-icon')
        ?.getAttribute('data-icon') ?? null;

    const voiceFromRemote = (
      overrides: Partial<ConstructorParameters<typeof ChatMessage>[0]> = {}
    ) =>
      ChatMessage.voice({
        id: 100,
        role: 'AGENT',
        timestamp,
        fileName: 'https://cdn/voice.ogg',
        amplitudes: [0.1, 0.5, 0.9],
        duration: 3000,
        ...overrides,
      });

    it('renders the play icon by default', async () => {
      const list = await renderList([voiceFromRemote()]);
      const voice = await getVoiceMessage(list);

      expect(getPlayButtonIcon(voice)).toBe('play');
    });

    it('starts playback and swaps to the pause icon when the play button is clicked', async () => {
      const list = await renderList([voiceFromRemote()]);
      const voice = await getVoiceMessage(list);

      getPlayButton(voice).click();
      await voice.updateComplete;

      expect(audioInstances).toHaveLength(1);
      expect(audioInstances[0].play).toHaveBeenCalledOnce();
      expect(getPlayButtonIcon(voice)).toBe('pause');
    });

    it('pauses playback and swaps back to the play icon when clicked again', async () => {
      const list = await renderList([voiceFromRemote()]);
      const voice = await getVoiceMessage(list);
      getPlayButton(voice).click();
      await voice.updateComplete;

      getPlayButton(voice).click();
      await voice.updateComplete;

      expect(audioInstances[0].pause).toHaveBeenCalledOnce();
      expect(getPlayButtonIcon(voice)).toBe('play');
    });

    it('reuses the same audio across play/pause cycles', async () => {
      const list = await renderList([voiceFromRemote()]);
      const voice = await getVoiceMessage(list);

      getPlayButton(voice).click();
      await voice.updateComplete;
      getPlayButton(voice).click();
      await voice.updateComplete;
      getPlayButton(voice).click();
      await voice.updateComplete;

      expect(audioInstances).toHaveLength(1);
      expect(audioInstances[0].play).toHaveBeenCalledTimes(2);
    });

    it('resets the icon to play when the audio finishes', async () => {
      const list = await renderList([voiceFromRemote()]);
      const voice = await getVoiceMessage(list);
      getPlayButton(voice).click();
      await voice.updateComplete;

      audioInstances[0].dispatchEvent(new Event('ended'));
      await voice.updateComplete;

      expect(getPlayButtonIcon(voice)).toBe('play');
    });

    it('uses a blob URL as the audio source when the message has a blob', async () => {
      const blob = new Blob(['audio'], { type: 'audio/webm' });
      const list = await renderList([
        ChatMessage.voice({
          id: 101,
          role: 'USER',
          timestamp,
          fileName: 'local-recording.webm',
          amplitudes: [0.2],
          duration: 1000,
          blob,
        }),
      ]);
      const voice = await getVoiceMessage(list);

      getPlayButton(voice).click();
      await voice.updateComplete;

      expect(URL.createObjectURL).toHaveBeenCalledWith(blob);
      expect(audioInstances[0].src).toBe('blob:fake-url');
    });

    it('falls back to fileName as the audio source when the message has no blob', async () => {
      const list = await renderList([voiceFromRemote()]);
      const voice = await getVoiceMessage(list);

      getPlayButton(voice).click();
      await voice.updateComplete;

      expect(audioInstances[0].src).toContain('https://cdn/voice.ogg');
      expect(URL.createObjectURL).not.toHaveBeenCalled();
    });

    it('pauses the audio when the voice element is removed from the DOM', async () => {
      const list = await renderList([voiceFromRemote()]);
      const voice = await getVoiceMessage(list);
      getPlayButton(voice).click();
      await voice.updateComplete;
      const audio = audioInstances[0];

      list.chatMessages = [];
      await list.updateComplete;

      expect(audio.pause).toHaveBeenCalledOnce();
    });
  });

  describe('video loading', () => {
    const getVideoMessage = async (
      list: ChatMessageList
    ): Promise<LitElement> => {
      const assistant = list.shadowRoot!.querySelector(
        'yalo-chat-assistant-message'
      ) as LitElement;
      await assistant.updateComplete;
      const videoMsg = assistant.shadowRoot!.querySelector(
        'yalo-chat-video-message'
      ) as LitElement;
      await videoMsg.updateComplete;
      return videoMsg;
    };

    const getVideoElement = (videoMsg: LitElement): HTMLVideoElement =>
      videoMsg.shadowRoot!.querySelector('video') as HTMLVideoElement;

    const videoFromRemote = () =>
      ChatMessage.video({
        id: 200,
        role: 'AGENT',
        timestamp,
        fileName: 'https://cdn/clip.mp4',
        duration: 10,
      });

    it('shows the loader spinner before the video data has loaded', async () => {
      const list = await renderList([videoFromRemote()]);
      const videoMsg = await getVideoMessage(list);

      expect(videoMsg.shadowRoot!.querySelector('.spinner')).not.toBeNull();
    });

    it('hides the loader spinner once the video fires loadeddata', async () => {
      const list = await renderList([videoFromRemote()]);
      const videoMsg = await getVideoMessage(list);

      getVideoElement(videoMsg).dispatchEvent(new Event('loadeddata'));
      await videoMsg.updateComplete;

      expect(videoMsg.shadowRoot!.querySelector('.spinner')).toBeNull();
    });

    it('hides the loader spinner once the video fires error', async () => {
      const list = await renderList([videoFromRemote()]);
      const videoMsg = await getVideoMessage(list);

      getVideoElement(videoMsg).dispatchEvent(new Event('error'));
      await videoMsg.updateComplete;

      expect(videoMsg.shadowRoot!.querySelector('.spinner')).toBeNull();
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

      const assistants = list.shadowRoot!.querySelectorAll(
        'yalo-chat-assistant-message'
      );
      const users = list.shadowRoot!.querySelectorAll('yalo-chat-user-message');
      expect(assistants).toHaveLength(1);
      expect(users).toHaveLength(1);
    });
  });
});
