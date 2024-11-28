class BoxModel{
  final String id;
  final String maSP;
  final String maThung;
  final String soLuongSP;
  final String maPhieuXuatKho;

  BoxModel({
    required this.id,
    required this.maSP,
    required this.maThung,
    required this.soLuongSP,
    required this.maPhieuXuatKho,
  });

  // Tạo phương thức từ và đến JSON
  factory BoxModel.fromJson(Map<String, dynamic> json) {
    return BoxModel(
      id: json['id'],
      maSP: json['maSP'],
      maThung: json['maThung'],
      soLuongSP: json['soLuongSP'],
      maPhieuXuatKho: json['maPhieuXuatKho'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'maSP': maSP,
      'maThung': maThung,
      'soLuongSP': soLuongSP,
      'maPhieuXuatKho' : maPhieuXuatKho,
    };
  }

}