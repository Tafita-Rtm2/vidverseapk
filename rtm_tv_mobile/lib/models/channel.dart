class Channel {
  final String id;
  final String name;
  final String? logo;
  final String? group;
  final String? country;

  Channel({
    required this.id,
    required this.name,
    this.logo,
    this.group,
    this.country,
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      id: json['id'].toString(),
      name: json['name'] ?? 'Unknown',
      logo: json['logo'],
      group: json['group'],
      country: json['country'],
    );
  }
}
