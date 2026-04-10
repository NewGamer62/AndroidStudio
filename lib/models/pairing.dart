class Pairing {
  final String relationCode;
  final String userPublicKey;
  final String? status;

  Pairing({required this.relationCode, required this.userPublicKey, this.status});

  Map<String, dynamic> toJson() => {
    'relationCode': relationCode,
    'userPublicKey': userPublicKey,
  };
}