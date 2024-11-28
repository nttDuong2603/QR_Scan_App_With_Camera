class WarehouseEntrySchedule {
  final String id;
  final String maPhieuXuatKho;
  final String ngayNhap;
  final String trangThai;

  WarehouseEntrySchedule({
    required this.id,
    required this.maPhieuXuatKho,
    required this.ngayNhap,
    required this.trangThai,
  });

  // Tạo phương thức từ và đến JSON
  factory WarehouseEntrySchedule.fromJson(Map<String, dynamic> json) {
    return WarehouseEntrySchedule(
      id: json['id'],
      maPhieuXuatKho: json['maPhieuXuatKho'],
      ngayNhap: json['ngayNhap'],
      trangThai: json['trangThai'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'maPhieuXuatKho': maPhieuXuatKho,
      'ngayNhap': ngayNhap,
      'trangThai': trangThai,
    };
  }
}
