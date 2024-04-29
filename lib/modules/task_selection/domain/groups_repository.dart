abstract class GroupsRepository {
  // Filtering groups is not supported by the api, so it will return all groups
  Future<List<Group>> list({
    int? pageSize,
  });
}

class Group {
  int id;
  String name;
  List<int> memberIds;

  Group({
    required this.id,
    required this.name,
    required this.memberIds,
  });
}
