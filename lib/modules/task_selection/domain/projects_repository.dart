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
  /// Numeric OpenProject id as returned by the API ("id"), used for reliable
  /// mapping with work package project links.
  final int? numericId;
  final String title;
  final DateTime? updatedAt;

  Project({
    required this.id,
    required this.numericId,
    required this.title,
    required this.updatedAt,
  });
}
