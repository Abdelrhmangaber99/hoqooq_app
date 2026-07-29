import 'package:freezed_annotation/freezed_annotation.dart';

part 'client.freezed.dart';

@freezed
abstract class Client with _$Client {
  const Client._();
  const factory Client({
    required String id,
    required String name,
    required String email,
    required String phone,
    required String area,
    required String status,
    required String info,
    required String address,
  }) = _Client;
}
