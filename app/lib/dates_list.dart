//import 'package:sqflite/sqflite.dart';
//
//
//class DatesList {
//
//}
//
//
//class DatesDB {
//  static const dbName = "presence.sql";
//  static const datesTable = "dates";
//  Future<Database> _db;
//
//  ProjectsDB() {
//    _db = () async {
////        await deleteDatabase(dbName);
//      return await openDatabase(dbName, version: 1, onCreate: (db, v) async {
//        print("creating DB...");
//        await db.execute('CREATE TABLE $datesTable('
//            'date TEXT PRIMARY KEY,'
//            'value TEXT,'
//            ')');
//        await db.execute('CREATE TABLE $tracksTable('
//            'trackId TEXT,'
//            'projectUuid TEXT'
//            ')');
//      },);
//    }();
//  }
//
//  Future<void> insertProject(String userId, ProjectConfiguration project) async {
//    final batch = (await _db).batch();
//    final projectJson = project.toJson();
//    projectJson['userId'] = userId;
//    List<String> trackIds = projectJson.remove('trackIds');
//    batch.insert(datesTable, projectJson);
//    for (var trackId in trackIds)
//      batch.insert(
//          tracksTable, {'trackId': trackId, 'projectUuid': project.uuid});
//    await batch.commit(noResult: true);
//    print("inserted new project: ${project.name}");
//    print(await (await _db).query(datesTable));
//  }
//
//  Future<void> updateProject(String projectId, {String newName, List<String> newPlaylistIds}) async {
//    final updateValues = <String, dynamic>{};
//    if (newName != null)
//      updateValues['name'] = newName;
//    if (newPlaylistIds != null)
//      updateValues['playlistIds'] = newPlaylistIds.join(';');
//    if (updateValues.length == 0)
//      return;
//    await (await _db).update(datesTable, updateValues, where: 'uuid = ?', whereArgs: [projectId]);
//  }
//
//  Future<void> updateIndex(String projectUuid, int index) async {
//    await (await _db).update(datesTable, {'curIndex': index},
//        where: "uuid = ?", whereArgs: [projectUuid]);
//  }
//
//  Future<DateTime> setIsArchived(String projectUuid, bool value) async {
//    final mtime = DateTime.now();
//    await (await _db).update(datesTable,
//        {'isArchived': value ? 1 : 0, 'lastModified': mtime.toIso8601String()},
//        where: "uuid = ?", whereArgs: [projectUuid]);
//    return mtime;
//  }
//
//  removeProject(String projectUuid) async {
//    final batch = (await _db).batch();
//    batch.delete(datesTable, where: 'uuid = ?', whereArgs: [projectUuid]);
//    batch.delete(tracksTable,
//        where: 'projectUuid = ?', whereArgs: [projectUuid]);
//    await batch.commit();
//  }
//
//  Future<List<ProjectConfiguration>> getProjectsConf(String userId) async {
//    final db = (await _db);
//    final futures =
//    (await db.query(
//        datesTable,
//        where: 'userId = ? OR '
//            'userId IS NULL', // historical reasons (when there wasn't userId column)
//        orderBy: "lastModified DESC",
//        whereArgs: [userId]))
//        .map((projectJson) async {
//      final uuid = projectJson['uuid'];
//      final tracks = (await db.query(tracksTable,
//          where: 'projectUuid = ?',
//          whereArgs: [uuid],
//          columns: ['trackId']))
//          .map<String>((tJson) => tJson['trackId'])
//          .toList();
//      return ProjectConfiguration.fromJson(projectJson, tracks);
//    });
//    return Future.wait(futures);
//  }
//
//  close() async {
//    (await _db).close();
//  }
//}
