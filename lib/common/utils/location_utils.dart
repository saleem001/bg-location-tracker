import 'package:geolocator/geolocator.dart';

class LocationUtils {
  /// Calculates the straight-line distance between two points in meters.
  static double calculateDistanceMeters(
    double currentLat,
    double currentLng,
    double destLat,
    double destLng,
  ) {
    return Geolocator.distanceBetween(currentLat, currentLng, destLat, destLng);
  }

  /// Using the famout veloctiy = distance / time formulat to calculate the ETA
  /// But it is not accurate because it does not consider the traffic and other factors
  ///
  // static DateTime? estimateArrivalTime(double distanceKm, double speedKmh) {
  //   if (speedKmh <= 1.0) return null; // Stationary or too slow to estimate

  //   final hours = distanceKm / speedKmh;
  //   final minutes = (hours * 60).round();

  //   return DateTime.now().add(Duration(minutes: minutes));
  // }

  /// Converts meters per second to kilometers per hour.
  static double msToKmh(double ms) {
    if (ms < 0) return 0.0;
    return ms * 3.6;
  }
}
