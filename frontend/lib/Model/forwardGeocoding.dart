class ForwardGeocoding {
  String formatted_address;
  double lat;
  double lng;
  String name;
  String district;
  String commune;
  String province;


  ForwardGeocoding({
    required this.formatted_address,
    required this.lat,
    required this.lng,
    required this.name,
    required this.district,
    required this.commune,
    required this.province,

  });

  factory ForwardGeocoding.fromJson(Map<String, dynamic> json) {
    return ForwardGeocoding(
      formatted_address: json['results'][0]['formatted_address'],
      lat: json['results'][0]['geometry']['location']['lat'],
      lng: json['results'][0]['geometry']['location']['lng'],
      name: json['results'][0]['name'],
      district: json['results'][0]['compound']['district'],
      commune: json['results'][0]['compound']['commune'],
      province: json['results'][0]['compound']['province'],
    );
  }
}