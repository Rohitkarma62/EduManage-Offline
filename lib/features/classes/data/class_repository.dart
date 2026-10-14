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

  Future<List<ClassBatchSession>> getBatches(int classId) => _database.getBatches(classId);
  Future<ClassBatchSession?> getBatch(int id) => _database.getBatch(id);
  Future<bool> batchExists({required int classId, required String name, int? excludingId}) =>
      _database.batchExists(classId: classId, name: name, excludingId: excludingId);
  Future<int> saveBatch({int? id, required int classId, required String name, String? subject, String? timing, String? teacherName, int? monthlyFeePaise}) =>
      _database.saveBatch(id: id, classId: classId, name: name, subject: subject, timing: timing, teacherName: teacherName, monthlyFeePaise: monthlyFeePaise);
  Future<void> setBatchActive(int id, {required bool isActive}) => _database.setBatchActive(id, isActive: isActive);
  Future<int> countBatches(int classId) => _database.countBatches(classId);
}
