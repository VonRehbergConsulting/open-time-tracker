abstract class ProjectsRepository {
  Future<List<Project>> list({
    String? userId,
    bool? active,
    int? pageSize,
    bool sortByName = false,
    bool assignedToUser = false,
  });
}

class Project {
  final String id;
  final String title;
  final DateTime? updatedAt;

  Project({
    required this.id,
    required this.title,
    required this.updatedAt,
  });
}
