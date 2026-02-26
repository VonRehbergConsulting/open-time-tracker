abstract class WorkPackagesRepository {
  Future<List<WorkPackage>> list({
    String? projectId,
    int? pageSize,
    Set<int>? statuses,
    String? user,
  });

  /// Returns a single page of work packages including pagination metadata.
  ///
  /// OpenProject API v3 returns collections that may be paginated. Pagination
  /// metadata includes `total`, `count`, `pageSize` and `offset` (page number).
  ///
  /// See: https://www.openproject.org/docs/api/collections/
  Future<WorkPackagesPage> listPaged({
    String? projectId,
    int? pageSize,
    int? offset,
    Set<int>? statuses,
    String? user,
  });
}

class WorkPackagesPage {
  final List<WorkPackage> items;
  final int total;
  final int count;
  final int? pageSize;
  final int? offset;

  const WorkPackagesPage({
    required this.items,
    required this.total,
    required this.count,
    required this.pageSize,
    required this.offset,
  });

  bool get hasNext {
    final ps = pageSize;
    final off = offset;
    if (ps == null || off == null) return false;
    if (count <= 0) return false;
    return (off * ps) < total;
  }

  int? get nextOffset {
    if (!hasNext) return null;
    final off = offset;
    if (off == null) return null;
    return off + 1;
  }
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
