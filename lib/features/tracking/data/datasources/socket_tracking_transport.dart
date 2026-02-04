
import '../../domain/entities/captain_location_data.dart';
import 'i_tracking_transport.dart';

class SocketTrackingTransport implements ITrackingTransport {

  @override
  Future<void> sendLocation(CaptainLocationData data) async {
    print('[SocketTransport] Sending location: ${data.toJson()}');
    await Future.delayed(Duration(milliseconds: 50)); 
  }

  @override
  Future<void> sendStationEntryAlert(String stationId) async {
    print('[SocketTransport] ENTER Station Alert: $stationId');
    await Future.delayed(Duration(milliseconds: 50));
  }
}
