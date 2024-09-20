abstract class ProjectsRepository {
  Future<List<Project>> list({
    String? userId,
    bool? active,
    int? pageSize,
  });
}

class Project {
  final String id;
  final String title;
  final DateTime? createdAt;

  Project({
    required this.id,
    required this.title,
    required this.createdAt,
  });
}
