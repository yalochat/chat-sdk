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
        const pageInfo1 = PageInfo(total: 100, page: 1);
        const pageInfo2 = PageInfo(total: 100, page: 2);

        expect(pageInfo1, isNot(equals(pageInfo2)));
      });

    });
  });

  group(Page, () {


    group('equality', () {
      test('should be equal when data and pageInfo match', () {
        const pageInfo = PageInfo(total: 2, page: 1);
        const page1 = Page<String>(
          data: ['a', 'b'],
          pageInfo: pageInfo,
        );
        const page2 = Page<String>(
          data: ['a', 'b'],
          pageInfo: pageInfo,
        );

        expect(page1, equals(page2));
        expect(page1.hashCode, equals(page2.hashCode));
      });

      test('should not be equal when data differs', () {
        const pageInfo = PageInfo(total: 2, page: 1);
        const page1 = Page<String>(
          data: ['a', 'b'],
          pageInfo: pageInfo,
        );
        const page2 = Page<String>(
          data: ['c', 'd'],
          pageInfo: pageInfo,
        );

        expect(page1, isNot(equals(page2)));
      });

      test('should not be equal when pageInfo differs', () {
        const page1 = Page<String>(
          data: ['a', 'b'],
          pageInfo: PageInfo(total: 2, page: 1),
        );
        const page2 = Page<String>(
          data: ['a', 'b'],
          pageInfo: PageInfo(total: 2, page: 2),
        );

        expect(page1, isNot(equals(page2)));
      });

    });

  });
}
