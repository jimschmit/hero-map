class Contact {
  int? id;
  String? createdAt;
  String? name;
  String? phoneNumber;
  String? email;
  late double lat;
  late double lng;
  String? additionalInfo;

  Contact(
      {this.id,
      this.createdAt,
      this.name,
      this.phoneNumber,
      this.email,
      required this.lat,
      required this.lng,
      this.additionalInfo});

  Contact.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['created_at'];
    name = json['name'];
    phoneNumber = json['phone_number'];
    email = json['email'];
    lat = json['lat'];
    lng = json['lng'];
    additionalInfo = json['additional_info'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['phone_number'] = phoneNumber;
    data['email'] = email;
    data['lat'] = lat;
    data['lng'] = lng;
    data['additional_info'] = additionalInfo;
    return data;
  }
}
