import 'dart:convert';

class TagEpc {
  final String epc;

  TagEpc({
    required this.epc,
  });

  factory TagEpc.fromMap(Map<String, dynamic> json) => TagEpc(
    epc: json["KEY_EPC"],
  );

  Map<String, dynamic> toMap() => {
    "KEY_EPC": epc,
  };

  static List<TagEpc> parseTags(String str) =>
      List<TagEpc>.from(json.decode(str).map((x) => TagEpc.fromMap(x)));

  static String tagEpcToJson(List<TagEpc> data) =>
      json.encode(List<dynamic>.from(data.map((x) => x.toMap())));
}
