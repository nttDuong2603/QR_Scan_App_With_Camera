class ProductModel{
  final String id;
  final String maSP;
  final String tenSP;
  final String soLuong;
  final String trangThaiSP;
  final String maPhieuXuatKho;

  ProductModel({
    required this.id,
    required this.maSP,
    required this.tenSP,
    required this.soLuong,
    required this.trangThaiSP,
    required this.maPhieuXuatKho,
});

  // Tạo phương thức từ và đến JSON
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      maSP: json['maSP'],
      tenSP: json['tenSP'],
      soLuong: json['soLuong'],
      trangThaiSP: json['trangThaiSP'],
      maPhieuXuatKho: json['maPhieuXuatKho'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'maSP': maSP,
      'tenSP': tenSP,
      'soLuong': soLuong,
      'trangThaiSP': trangThaiSP,
      'maPhieuXuatKho' : maPhieuXuatKho,
    };
  }

}