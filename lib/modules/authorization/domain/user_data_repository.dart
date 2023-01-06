abstract class UserDataRepository {
  int? get userID;

  Future<int?> loadUserID();
}
