class LocationInfo {
  double? lat;
  double? lng;
  String? roadaddr;
  String? address;
  String? detail;

  LocationInfo(
      {required this.lat,
      required this.lng,
      this.roadaddr,
      this.address,
      this.detail});

  factory LocationInfo.fromJson(Map<String, dynamic> json) {
    return LocationInfo(
        lat: json['lat'],
        lng: json['lng'],
        roadaddr: json['roadaddr'] ?? "",
        address: json['address'] ?? "",
        detail: json['detail'] ?? "");
  }

  Map<String, dynamic> toJson() => {
        "lat": lat!.toDouble(),
        "lng": lng!.toDouble(),
        "address": address,
        "roadaddr": roadaddr,
        "detail": detail
      };
}
