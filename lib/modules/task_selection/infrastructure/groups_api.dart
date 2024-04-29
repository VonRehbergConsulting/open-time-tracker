import 'package:dio/dio.dart';
import 'package:retrofit/http.dart';

part 'groups_api.g.dart';

@RestApi()
abstract class GroupsApi {
  factory GroupsApi(Dio dio) = _GroupsApi;

  @GET('/groups')
  Future<GroupListResponse> groups({
    @Query('pageSize') int? pageSize,
  });
}

class GroupResponse {
  late int id;
  late String name;
  late List<int> memberIds;

  GroupResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];

    final links = json['_links'];
    final members = links['members'] as List<dynamic>;
    memberIds = members
        .map((e) => int.parse((e['href'] as String).split('/').last))
        .toList();
  }
}

class GroupListResponse {
  late List<GroupResponse> groups;

  GroupListResponse.fromJson(Map<String, dynamic> json) {
    List<GroupResponse> items = [];
    final embedded = json['_embedded'];
    final elements = embedded['elements'] as List<dynamic>;
    for (final element in elements) {
      items.add(GroupResponse.fromJson(element));
    }
    groups = items;
  }
}
