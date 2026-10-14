import '../../../core/database/app_database.dart';

class StudentRepository {
  const StudentRepository(this._database);
  final AppDatabase _database;

  Future<List<Student>> getStudents({String query = ''}) =>
      _database.searchStudents(query);

  Future<Student?> getStudent(int id) => _database.getStudent(id);

  Future<int> saveStudent({
    int? id,
    required String admissionNumber,
    required String fullName,
    String? phone,
    String? guardianName,
  }) =>
      _database.saveStudent(
        id: id,
        admissionNumber: admissionNumber,
        fullName: fullName,
        phone: phone,
        guardianName: guardianName,
      );

  Future<void> setStudentActive(int id, {required bool isActive}) =>
      _database.setStudentActive(id, isActive: isActive);
}
