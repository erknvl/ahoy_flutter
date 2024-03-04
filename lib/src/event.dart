class Event {
  final String? id;
  final String name;
  final Map<String, dynamic> properties;
  final DateTime time;

  Event({
    this.id,
    required this.name,
    required this.properties,
    DateTime? time,
  }) : time = time ?? DateTime.now();

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      name: json['name'],
      properties: json['properties'],
      time: DateTime.parse(json['time']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'properties': properties,
      'time': time.toIso8601String(),
    };
  }
}
