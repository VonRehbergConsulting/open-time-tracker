import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:retrofit/retrofit.dart';

part 'user_data_api.g.dart';

@RestApi()
abstract class UserDataApi {
  factory UserDataApi(Dio dio) = _UserDataApi;

  @GET('/users/me')
  Future<UserData> getUserData();
}

@JsonSerializable()
class UserData {
  int id;

  UserData({
    required this.id,
  });

  factory UserData.fromJson(Map<String, dynamic> json) =>
      _$UserDataFromJson(json);
}
