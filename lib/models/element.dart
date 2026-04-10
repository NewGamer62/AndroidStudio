class ElementModel {
  final String relationCode;
  final String key;
  final String value;

  ElementModel({required this.relationCode, required this.key, required this.value});

  factory ElementModel.fromJson(Map<String, dynamic> json) {
    return ElementModel(
      relationCode: json['relationCode'] ?? '',
      key: json['key'] ?? 'MESSAGE',
      value: json['value'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'relationCode': relationCode,
    'key': key,
    'value': value,
  };
}