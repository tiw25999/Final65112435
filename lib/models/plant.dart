class Plant {
  final int? id;
  final String name;
  final String scientificName;
  final String imagePath;

  Plant({
    this.id,
    required this.name,
    required this.scientificName,
    required this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'plantID': id,
      'plantName': name,
      'plantScientific': scientificName,
      'plantImage': imagePath,
    };
  }

  factory Plant.fromMap(Map<String, dynamic> map) {
    return Plant(
      id: map['plantID'],
      name: map['plantName'],
      scientificName: map['plantScientific'],
      imagePath: map['plantImage'],
    );
  }
}
