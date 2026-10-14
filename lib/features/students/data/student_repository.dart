import '../../../core/database/app_database.dart';

class StudentRepository {
  const StudentRepository(this._database);
  final AppDatabase _database;

  Future<List<Student>> getStudents({String query = ''}) =>
      _database.searchStudents(query);

  Future<Student?> getStudent(int id) => _database.getStudent(id);

  Future<bool> admissionNumberExists({
    required String admissionNumber,
    int? excludingId,
  }) =>
      _database.studentAdmissionNumberExists(
        admissionNumber: admissionNumber,
        excludingId: excludingId,
      );

  Future<int> saveStudent({
    int? id,
    required String admissionNumber,
    required String fullName,
    String? phone,
    String? guardianName,
    int? classId,
  }) =>
      _database.saveStudent(
        id: id,
        admissionNumber: admissionNumber,
        fullName: fullName,
        phone: phone,
        guardianName: guardianName,
        classId: classId,
      );

  Future<List<StudentAssignment>> getAssignmentHistory(int studentId) =>
      _database.getStudentAssignmentHistory(studentId);

  Future<StudentAssignment?> getCurrentAssignment(int studentId) =>
      _database.getCurrentStudentAssignment(studentId);

  Future<int> transferStudent({
    required int studentId,
    required int classId,
    int? batchId,
    required DateTime effectiveFrom,
    String? reason,
  }) =>
      _database.assignStudentToClass(
        studentId: studentId,
        classId: classId,
        batchId: batchId,
        effectiveFrom: effectiveFrom,
        reason: reason,
      );

  Future<void> setStudentActive(int id, {required bool isActive}) =>
      _database.setStudentActive(id, isActive: isActive);
}
