class Property {
  final int id;
  final String imageSrc;
  final String title;
  final String type;
  final String price;
  final String location;
  final int bedrooms;
  final int bathrooms;
  final String area;
  final String description;

  Property({
    required this.id,
    required this.imageSrc,
    required this.title,
    required this.type,
    required this.price,
    required this.location,
    required this.bedrooms,
    required this.bathrooms,
    required this.area,
    required this.description,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'],
      imageSrc: json['imageSrc'],
      title: json['title'],
      type:json['type'],
      price: json['price'],
      location: json['location'],
      bedrooms: json['bedrooms'],
      bathrooms: json['bathrooms'],
      area: json['area'],
      description: json['description'],
    );
  }
}
