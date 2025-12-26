// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/domain/models/product/product.dart';
import 'package:test/test.dart';

void main() {
  group('Product class tests', () {
    test('should create Product with required fields', () {
      const product = Product(
        sku: 'SKU123',
        name: 'Test Product',
        price: 10.0,
        unitName: 'box',

      );

      expect(product.sku, equals('SKU123'));
      expect(product.name, equals('Test Product'));
      expect(product.price, equals(10.0));
      expect(product.unitName, equals('box'));
    });

    test('should have default values for optional fields', () {
      const product = Product(
        sku: 'SKU123',
        name: 'Test Product',
        price: 10.0,
        unitName: 'box',
      );

      expect(product.imagesUrl, equals([]));
      expect(product.salePrice, isNull);
      expect(product.subunits, equals(1));
      expect(product.unitStep, equals(1));
      expect(product.subunitStep, equals(1));
      expect(product.unitsAdded, equals(0));
      expect(product.subunitsAdded, equals(0));
    });

    test('should create Product with all fields', () {
      const product = Product(
        sku: 'SKU456',
        name: 'Full Product',
        price: 20.0,
        imagesUrl: ['image1.jpg', 'image2.jpg'],
        salePrice: 15.0,
        subunits: 12,
        unitStep: 2,
        unitName: 'box',
        subunitName: 'piece',
        subunitStep: 3,
        unitsAdded: 5,
        subunitsAdded: 60,
      );

      expect(product.sku, equals('SKU456'));
      expect(product.salePrice, equals(15.0));
      expect(product.subunits, equals(12));
      expect(product.imagesUrl.length, equals(2));
      expect(product.subunitName, equals('piece'));
    });

    test('copyWith should return new instance with updated fields', () {
      const original = Product(
        sku: 'SKU123',
        name: 'Original',
        price: 10.0,
        unitName: 'box',
      );

      final updated = original.copyWith(name: 'Updated', price: 15.0);

      expect(updated.name, equals('Updated'));
      expect(updated.price, equals(15.0));
      expect(updated.sku, equals(original.sku));
    });

    test('copyWith should handle null values for optional fields', () {
      const original = Product(
        sku: 'SKU123',
        name: 'Original',
        price: 10.0,
        salePrice: 8.0,
        unitName: 'box',
      );

      final updated = original.copyWith(
        salePrice: () => null,
        subunitName: () => 'boxes',
      );

      expect(updated.salePrice, isNull);
      expect(updated.price, equals(original.price));

      final updated2 = original.copyWith(salePrice: null);
      expect(updated2.salePrice, equals(original.salePrice));
    });

    test('should be equal when all properties are same', () {
      const product1 = Product(
        sku: 'SKU123',
        name: 'Test',
        price: 10.0,
        unitName: 'box',
      );

      const product2 = Product(
        sku: 'SKU123',
        name: 'Test',
        price: 10.0,
        unitName: 'box',
      );

      expect(product1, equals(product2));
    });

    test('should not be equal when properties differ', () {
      const product1 = Product(
        sku: 'SKU123',
        name: 'Test',
        price: 10.0,
        unitName: 'box',
      );

      const product2 = Product(
        sku: 'SKU456',
        name: 'Test',
        price: 10.0,
        unitName: 'box',
      );

      expect(product1, isNot(equals(product2)));
    });

    test('toJson should convert to Map', () {
      const product = Product(
        sku: 'SKU123',
        name: 'Test Product',
        price: 10.0,
        unitName: 'box',
      );

      final json = product.toJson();

      expect(json, isA<Map<String, dynamic>>());
      expect(json['sku'], equals('SKU123'));
      expect(json['name'], equals('Test Product'));
      expect(json['price'], equals(10.0));
    });

    test('fromJson should create Product from Map', () {
      final json = {
        'sku': 'SKU123',
        'name': 'Test Product',
        'price': 10.0,
        'unitName': 'box',
        'unitNamePlural': 'boxes',
        'imagesUrl': <String>[],
        'subunits': 1.0,
        'unitStep': 1.0,
        'subunitStep': 1.0,
        'unitsAdded': 0.0,
        'subunitsAdded': 0.0,
      };

      final product = Product.fromJson(json);

      expect(product.sku, equals('SKU123'));
      expect(product.name, equals('Test Product'));
      expect(product.price, equals(10.0));
    });
  });
}
