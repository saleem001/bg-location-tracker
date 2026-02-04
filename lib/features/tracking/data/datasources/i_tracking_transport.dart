
import '../../domain/entities/captain_location_data.dart';

abstract class ITrackingTransport {
  Future<void> sendLocation(CaptainLocationData data);
  Future<void> sendStationEntryAlert(String stationId);
}
