// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/common/result.dart';
import 'package:test/test.dart';

void main() {
  group(Result, () {
    group(Ok, () {
      test('creates Ok result with value', () {
        const result = Result.ok(42);
        expect(result, isA<Ok<int>>());
        expect((result as Ok<int>).result, equals(42));
      });

      test('equality works correctly', () {
        const result1 = Result.ok('test');
        const result2 = Result.ok('test');
        const result3 = Result.ok('different');

        expect(result1, equals(result2));
        expect(result1, isNot(equals(result3)));
      });
    });

    group(Error, () {
      test('creates Error result with exception', () {
        final exception = Exception('Test error');
        final result = Result<String>.error(exception);

        expect(result, isA<Error<String>>());
        expect((result as Error<String>).error, equals(exception));
      });

      test('equality works correctly', () {
        final exception1 = Exception('Error 1');
        final exception2 = Exception('Error 2');

        final result1 = Result<int>.error(exception1);
        final result2 = Result<int>.error(exception1);
        final result3 = Result<int>.error(exception2);

        expect(result1, equals(result2));
        expect(result1, isNot(equals(result3)));
      });
    });

    test('Ok and Error are not equal', () {
      const okResult = Result.ok(42);
      final errorResult = Result<int>.error(Exception('Error'));

      expect(okResult, isNot(equals(errorResult)));
    });
  });
}
