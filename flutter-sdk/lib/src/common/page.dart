// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:equatable/equatable.dart';

class PageInfo extends Equatable {
  final int? total;
  final int? totalPages;
  final int? page;
  final int? cursor;
  final int? nextCursor;
  final int? prevCursor;
  final int pageSize;

  const PageInfo({
    this.total,
    this.totalPages,
    this.page,
    this.cursor,
    this.nextCursor,
    this.prevCursor,
    required this.pageSize,
  });

  PageInfo copyWith({
    int? total,
    int? totalPages,
    int? page,
    int? cursor,
    int? nextCursor,
    int? prevCursor,
    int? pageSize,
  }) {
    return PageInfo(
      total: total ?? this.total,
      totalPages: totalPages ?? this.totalPages,
      page: page ?? this.page,
      cursor: cursor ?? this.cursor,
      nextCursor: nextCursor ?? this.nextCursor,
      prevCursor: prevCursor ?? this.prevCursor,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  @override
  List<Object?> get props => [
    total,
    totalPages,
    page,
    cursor,
    nextCursor,
    prevCursor,
    pageSize,
  ];
}

class Page<T> extends Equatable {
  final List<T> data;
  final PageInfo pageInfo;

  const Page({required this.data, required this.pageInfo});

  Page<T> copyWith({List<T>? data, PageInfo? pageInfo}) {
    return Page<T>(
      data: data ?? this.data,
      pageInfo: pageInfo ?? this.pageInfo,
    );
  }

  @override
  List<Object?> get props => [data, pageInfo];
}
