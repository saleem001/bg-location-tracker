import 'package:track_me/common/models/tracking_events.dart';

class ActivityChangeEvent {
  final String activity;
  final int confidence;
  ActivityChangeEvent({required this.activity, required this.confidence});
}

class ProviderChangeEvent {
  final bool enabled;
  final int status;
  final bool network;
  final bool gps;
  ProviderChangeEvent({
    required this.enabled,
    required this.status,
    required this.network,
    required this.gps,
  });
}

class HttpEvent {
  final bool success;
  final int status;
  final String responseText;
  HttpEvent({
    required this.success,
    required this.status,
    required this.responseText,
  });
}

class DomainTransistorToken {
  final String accessToken;
  final String refreshToken;
  final int expires;
  final String url;
  DomainTransistorToken({
    required this.accessToken,
    required this.refreshToken,
    required this.expires,
    required this.url,
  });
}
