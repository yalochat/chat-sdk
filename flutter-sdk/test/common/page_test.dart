// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/common/page.dart';
import 'package:test/test.dart';

void main() {
  group(PageInfo, () {
    group('equality', () {
      test('should be equal when all properties match', () {
        const pageInfo1 = PageInfo(
          total: 100,
          totalPages: 10,
          page: 1,
          pageSize: 10,
        );
        const pageInfo2 = PageInfo(
          total: 100,
          totalPages: 10,
          page: 1,
          pageSize: 10,
        );

        expect(pageInfo1, equals(pageInfo2));
        expect(pageInfo1.hashCode, equals(pageInfo2.hashCode));
      });

      test('should not be equal when properties differ', () {
        const pageInfo1 = PageInfo(total: 100, page: 1, pageSize: 30);
        const pageInfo2 = PageInfo(total: 100, page: 2, pageSize: 30);

        expect(pageInfo1, isNot(equals(pageInfo2)));
      });
    });
    group('PageInfo copyWith', () {
      const original = PageInfo(
        total: 100,
        totalPages: 10,
        page: 1,
        cursor: 50,
        nextCursor: 75,
        prevCursor: 25,
        pageSize: 10,
      );

      test('returns same object when no parameters provided', () {
        final copied = original.copyWith();
        expect(copied, equals(original));
      });

      test('updates single field correctly', () {
        final copied = original.copyWith(total: 200);
        expect(copied.total, equals(200));
        expect(copied.page, equals(1));
      });

      test('updates multiple fields correctly', () {
        final copied = original.copyWith(total: 200, page: 2, pageSize: 20);
        expect(copied.total, equals(200));
        expect(copied.page, equals(2));
        expect(copied.pageSize, equals(20));
        expect(copied.cursor, equals(50));
      });
    });
  });

  group(Page, () {
    group('equality', () {
      test('should be equal when data and pageInfo match', () {
        const pageInfo = PageInfo(total: 2, page: 1, pageSize: 30);
        const page1 = Page<String>(data: ['a', 'b'], pageInfo: pageInfo);
        const page2 = Page<String>(data: ['a', 'b'], pageInfo: pageInfo);

        expect(page1, equals(page2));
        expect(page1.hashCode, equals(page2.hashCode));
      });

      test('should not be equal when data differs', () {
        const pageInfo = PageInfo(total: 2, page: 1, pageSize: 30);
        const page1 = Page<String>(data: ['a', 'b'], pageInfo: pageInfo);
        const page2 = Page<String>(data: ['c', 'd'], pageInfo: pageInfo);

        expect(page1, isNot(equals(page2)));
      });

      test('should not be equal when pageInfo differs', () {
        const page1 = Page<String>(
          data: ['a', 'b'],
          pageInfo: PageInfo(total: 2, page: 1, pageSize: 30),
        );
        const page2 = Page<String>(
          data: ['a', 'b'],
          pageInfo: PageInfo(total: 2, page: 2, pageSize: 30),
        );

        expect(page1, isNot(equals(page2)));
      });

      test('', () {});
    });
    group('Page copyWith', () {
      final originalData = [1, 2, 3];
      const originalPageInfo = PageInfo(pageSize: 10, total: 100);
      final original = Page(data: originalData, pageInfo: originalPageInfo);

      test('returns same object when no parameters provided', () {
        final copied = original.copyWith();
        expect(copied, equals(original));
      });

      test('updates data correctly', () {
        final newData = [4, 5, 6];
        final copied = original.copyWith(data: newData);
        expect(copied.data, equals(newData));
        expect(copied.pageInfo, equals(originalPageInfo));
      });

      test('updates pageInfo correctly', () {
        const newPageInfo = PageInfo(pageSize: 20, total: 200);
        final copied = original.copyWith(pageInfo: newPageInfo);
        expect(copied.pageInfo, equals(newPageInfo));
        expect(copied.data, equals(originalData));
      });

    });
  });
}
