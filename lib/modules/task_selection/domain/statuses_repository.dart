abstract class StatusesRepository {
  Future<List<Status>> list();
}

class Status {
  final int id;
  final String name;

  const Status({
    required this.id,
    required this.name,
  });
}
