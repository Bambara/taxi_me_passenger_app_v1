class PassengerRideModel {
  final String passengerId;
  final String address;
  final double latitude;
  final double longitude;
  final String operationRadius;
  final String dropLocations;
  final String distance;
  final String bidValue;
  final String vehicleCategory;
  final String vehicleSubCategory;
  final String hireCost;
  final String type;
  final String validTime;
  final String payMethod;

  PassengerRideModel({
    required this.passengerId,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.operationRadius,
    required this.dropLocations,
    required this.distance,
    required this.bidValue,
    required this.vehicleCategory,
    required this.vehicleSubCategory,
    required this.hireCost,
    required this.type,
    required this.validTime,
    required this.payMethod,
  });

  factory PassengerRideModel.fromJson(Map<dynamic, dynamic> json) {
    return PassengerRideModel(
      passengerId: json['passengerId'],
      address: json['address'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      operationRadius: json['operationRadius'],
      dropLocations: json['dropLocations'],
      distance: json['distance'],
      bidValue: json['bidValue'],
      vehicleCategory: json['vehicleCategory'],
      vehicleSubCategory: json['vehicleSubCategory'],
      hireCost: json['hireCost'],
      type: json['type'],
      validTime: json['validTime'],
      payMethod: json['payMethod'],
    );
  }
}
