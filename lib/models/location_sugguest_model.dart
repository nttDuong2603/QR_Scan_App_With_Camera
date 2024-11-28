class LocationSugguestModel{
  final String id;
  final String viTri;
  final String  maPhieuXuatKho;

  LocationSugguestModel({
    required this.id,
    required this.viTri,
    required this.maPhieuXuatKho,
  });

  // Tạo phương thức từ và đến JSON
  factory LocationSugguestModel.fromJson(Map<String, dynamic> json) {
    return LocationSugguestModel(
      id: json['id'],
      viTri: json['viTri'],
      maPhieuXuatKho: json['maPhieuXuatKho'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'viTri': viTri,
      'maPhieuXuatKho' : maPhieuXuatKho,
    };
  }

}