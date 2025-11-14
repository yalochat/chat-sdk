// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:equatable/equatable.dart';

class PageInfo extends Equatable {
  final int? total;
  final int? totalPages;
  final int page;
  final int pageSize;

  const PageInfo({
    this.total,
    this.totalPages,
    required this.page,
    required this.pageSize,
  });

  @override
  List<Object?> get props => [total, totalPages, page, pageSize];
}

class Page<T> extends Equatable {
  final List<T> data;
  final PageInfo? pageInfo;

  const Page({required this.data, required this.pageInfo});

  @override
  List<Object?> get props => [data, pageInfo];
}
