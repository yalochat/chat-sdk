// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
  sku: json['sku'] as String,
  name: json['name'] as String,
  price: (json['price'] as num).toDouble(),
  imagesUrl:
      (json['imagesUrl'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  salePrice: (json['salePrice'] as num?)?.toDouble(),
  subunits: (json['subunits'] as num?)?.toDouble() ?? 1,
  unitStep: (json['unitStep'] as num?)?.toDouble() ?? 1,
  unitName: json['unitName'] as String,
  unitNamePlural: json['unitNamePlural'] as String,
  subunitName: json['subunitName'] as String?,
  subunitNamePlural: json['subunitNamePlural'] as String?,
  subunitStep: (json['subunitStep'] as num?)?.toDouble() ?? 1,
  unitsAdded: (json['unitsAdded'] as num?)?.toDouble() ?? 0,
  subunitsAdded: (json['subunitsAdded'] as num?)?.toDouble() ?? 0,
);

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
  'sku': instance.sku,
  'name': instance.name,
  'price': instance.price,
  'imagesUrl': instance.imagesUrl,
  'salePrice': instance.salePrice,
  'subunits': instance.subunits,
  'unitStep': instance.unitStep,
  'unitName': instance.unitName,
  'unitNamePlural': instance.unitNamePlural,
  'subunitName': instance.subunitName,
  'subunitNamePlural': instance.subunitNamePlural,
  'subunitStep': instance.subunitStep,
  'unitsAdded': instance.unitsAdded,
  'subunitsAdded': instance.subunitsAdded,
};
