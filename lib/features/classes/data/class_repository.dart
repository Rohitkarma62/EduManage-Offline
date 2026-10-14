import '../../../core/database/app_database.dart';

class ClassRepository {
  const ClassRepository(this._database);
  final AppDatabase _database;

  Future<List<ClassBatch>> getClasses({String query = ''}) =>
      _database.searchClasses(query);

  Future<ClassBatch?> getClass(int id) => _database.getClass(id);

  Future<bool> classExists({
    required String name,
    required String academicYear,
    int? excludingId,
  }) =>
      _database.classExists(
        name: name,
        academicYear: academicYear,
        excludingId: excludingId,
      );

  Future<int> saveClass({
    int? id,
    required String name,
    required String academicYear,
    String? description,
  }) =>
      _database.saveClass(
        id: id,
        name: name,
        academicYear: academicYear,
        description: description,
      );

  Future<void> setClassActive(int id, {required bool isActive}) =>
      _database.setClassActive(id, isActive: isActive);
}
