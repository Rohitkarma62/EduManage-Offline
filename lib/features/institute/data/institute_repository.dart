import '../../../core/database/app_database.dart';

class InstituteRepository {
  const InstituteRepository(this._database);

  final AppDatabase _database;

  Future<Institute?> getInstitute() => _database.getInstitute();

  Future<void> saveInstitute({
    required String name,
    required String academicYear,
    String? phone,
  }) {
    return _database.saveInstitute(
      name: name,
      academicYear: academicYear,
      phone: phone,
    );
  }
}
