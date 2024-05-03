abstract class WorkPackagesRepository {
  Future<List<WorkPackage>> list({
    int? pageSize,
    Set<int>? statuses,
  });
}

enum WorkPackageAssigneeType {
  user,
  group,
}

class WorkPackageAssignee {
  final WorkPackageAssigneeType type;
  final String title;

  const WorkPackageAssignee({
    required this.type,
    required this.title,
  });
}

class WorkPackage {
  int id;
  String subject;
  String href;
  String projectTitle;
  String projectHref;
  String priority;
  String status;
  WorkPackageAssignee assignee;

  WorkPackage({
    required this.id,
    required this.subject,
    required this.href,
    required this.projectTitle,
    required this.projectHref,
    required this.priority,
    required this.status,
    required this.assignee,
  });
}
