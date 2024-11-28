import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('warehouse.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE warehouse_entry_schedule (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        maPhieuXuatKho TEXT,
        ngayNhap TEXT NOT NULL,
        trangThai TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE product (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        maSP TEXT NOT NULL,
        tenSP TEXT NOT NULL,
        soLuong INTEGER NOT NULL,
        trangThaiSP TEXT NOT NULL,
        maPhieuXuatKho INTEGER NOT NULL,
        FOREIGN KEY (maPhieuXuatKho) REFERENCES warehouse_entry_schedule (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE box (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        maThung TEXT NOT NULL,
        maPhieuXuatKho INTEGER NOT NULL,
        soLuongSP INTEGER NOT NULL,
        FOREIGN KEY (maPhieuXuatKho) REFERENCES warehouse_entry_schedule (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE box_product (
        box_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        PRIMARY KEY (box_id, product_id),
        FOREIGN KEY (box_id) REFERENCES box (id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES product (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE location_suggestion (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        viTri TEXT NOT NULL,
        maPhieuXuatKho INTEGER NOT NULL,
        FOREIGN KEY (maPhieuXuatKho) REFERENCES warehouse_entry_schedule (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE location_box (
        location_id INTEGER NOT NULL,
        box_id INTEGER NOT NULL,
        PRIMARY KEY (location_id, box_id),
        FOREIGN KEY (location_id) REFERENCES location_suggestion (id) ON DELETE CASCADE,
        FOREIGN KEY (box_id) REFERENCES box (id) ON DELETE CASCADE
      )
    ''');
  }

  Future close() async {
    final db = _database;
    if (db != null) {
      await db.close();
    }
  }
}
