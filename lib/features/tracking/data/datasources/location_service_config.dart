
class LocationServiceConfig {
  final bool includeBattery;
  final bool includeDevice;
  final bool includeGps;
  final bool includeInternet;
  final String? captainId;
  final String? rideId;
  final String? tripStatus;

  const LocationServiceConfig({
    this.includeBattery = true,
    this.includeDevice = true,
    this.includeGps = true,
    this.includeInternet = true,
    this.captainId,
    this.rideId,
    this.tripStatus,
  });

  LocationServiceConfig copyWith({
    bool? includeBattery,
    bool? includeDevice,
    bool? includeGps,
    bool? includeInternet,
    String? captainId,
    String? rideId,
    String? tripStatus,
  }) {
    return LocationServiceConfig(
      includeBattery: includeBattery ?? this.includeBattery,
      includeDevice: includeDevice ?? this.includeDevice,
      includeGps: includeGps ?? this.includeGps,
      includeInternet: includeInternet ?? this.includeInternet,
      captainId: captainId ?? this.captainId,
      rideId: rideId ?? this.rideId,
      tripStatus: tripStatus ?? this.tripStatus,
    );
  }
}
