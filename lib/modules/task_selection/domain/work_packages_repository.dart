abstract class WorkPackagesRepository {
  Future<List<WorkPackage>> list({
    int? userId,
    int? pageSize,
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

  WorkPackage({
    required this.id,
    required this.subject,
    required this.href,
    required this.projectTitle,
    required this.projectHref,
    required this.priority,
    required this.status,
  });
}
