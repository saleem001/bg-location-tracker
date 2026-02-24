# Background Location Tracker - Project Documentation

## 1. Overview
The `bg_location_tracker` package is a high-performance background tracking and geofencing engine for the Captain App. It ensures the backend and the Captain are always synchronized with the real-time state of a trip, even when the application is terminated or the phone is in a pocket.

---

## 2. System Architecture (Module Interaction)
The project is built on a "Reactive Observer" architecture. The **Service Manager** emits raw events, which are aggregated and then observed by multiple independent modules.

```mermaid
graph TD
    subgraph Native Layer
        BG[Background Geolocation Plugin]
    end

    subgraph Core Layer
        SM[BackgroundLocationServiceManager]
        AGG[LocationEventAggregator]
    end

    subgraph Service Layer
        SYNC[SocketSyncService]
        NOTIF[GeofenceNotificationHandler]
        LVM[LocationTrackerViewModel <br/> Singleton]
    end

    subgraph Entry Points
        HT[Headless Task Runner]
        RDS[RideDetailScreen]
        NAV[NavigationScreen]
    end

    BG --> SM
    SM --> AGG
    AGG --> SYNC
    AGG --> NOTIF
    AGG --> LVM
    LVM --> NAV
    BG --> HT
    HT --> SYNC
    HT --> NotificationService
```

---

## 3. Lifecycle Sequence Diagram: From Ride Detail to Navigation
This diagram shows the complete flow: from one-shot location in Ride Details, to starting a ride via API, and finally activating background geofencing in Navigation.

```mermaid
sequenceDiagram
    participant RDS as RideDetailScreen
    participant RDVM as RideDetailViewModel
    participant NAV as NavigationScreen
    participant LVM as LocationTrackerViewModel (Singleton)
    participant SM as ServiceManager
    participant API as Backend API (REST/Socket)
    participant NOTIF as NotificationService

    Note over RDS, SM: 1. Preparation (One-Shot Location)
    RDS->>LVM: getCurrentPosition()
    LVM->>SM: Get position Samples(1)
    SM-->>RDS: Display current Lat/Lng on Map

    Note over RDS, API: 2. Vehicle Confirmation & Setup
    RDS->>RDVM: Click "Confirm Vehicle"
    RDVM->>API: POST /api/ride/start
    API-->>RDVM: 200 OK (Returns Stations List)
    RDVM->>NAV: Redirect with Stations Data

    Note over NAV, API: 3. Active Tracking Mode (Foreground)
    NAV->>LVM: startTrip(stations)
    LVM->>SM: initialize() & start()
    LVM->>SM: addOnGeofence(stations) & addOnMotionChange()
    
    Note over SM, API: 4. Auto Arrival / Depart Detection
    SM->>LVM: GEOFENCE ENTER (Arrived)
    par Observers
        LVM->>NAV: Update UI (Show Arrived Status)
        SM->>NOTIF: Show Local Notification Popup
        SM->>API: Call Arrival API (/api/trip/arrival)
    end

    Note over SM, API: 5. Background / Headless Mode
    Note right of SM: App Is Dead
    SM->>API: Headless Task calls Arrival/Depart API
    SM->>SM: Show System Notification
```

---

## 4. Geofence Flow: Auto Arrival & Depart
The system handles geofencing automatically. When a Captain enters or exits a predefined diameter (station), the following logic triggers.

```mermaid
graph TD
    A[Geofence Event] --> B{Action Type?}
    B -->|ENTER| C[Arrival Detected]
    B -->|EXIT| D[Depart Detected]

    C --> C1[Notification: 'You have arrived at Station']
    C --> C2[Transport: Call sendArrivalAlert API]

    D --> D1[Notification: 'You have departed from Station']
    D --> D2[Transport: Call sendDepartAlert API]
```

---

## 5. Implementation Guide

### Phase 1: Ride Detail Screen (Preparation)
Initialize the singleton but do not start the "Trip". This saves battery while providing the current location for the map.

```dart
// RideDetailViewModel logic
final lvm = LocationTrackerViewModel();
final currentPos = await lvm.getCurrentPosition();

// On Confirm Vehicle
final stations = await api.startRide(rideId);
Navigator.push(context, NavigationScreen(stations: stations));
```

### Phase 2: Navigation Screen (Active Tracking)
This starts the background powerhouse. It enables:
- **Motion Change**: High-frequency updates only when moving.
- **Geofences**: Triggers Arrival/Depart status.
- **Socket Sync**: Real-time position on your dashboard.

```dart
// NavigationScreen logic
@override
void initState() {
  super.initState();
  LocationTrackerViewModel().startTrip(
    stations: widget.stations,
    captainId: captainId,
    rideId: rideId
  );
}
```

### Phase 3: Global Headless Setup (`main.dart`)
Must be registered at the root to handle events when the app is NOT running.

```dart
@pragma('vm:entry-point')
void backgroundGeolocationHeadlessTask(bg.HeadlessEvent event) async {
  if (event.name == bg.Event.GEOFENCE) {
    // Call Arrival/Depart APIs directly from transport
  }
}
```

---

## 7. Headless Task Deep Dive (App Killed State)
When the application is in a **Killed State** (removed from recent apps or terminated by OS), the Dart UI code is not running. However, the Native Plugin continues to operate and executes the `Headless Task` isolate.

### A. Headless Arrival & Depart Flow (Killed State)
This diagram shows how the system handles station logic when the user is NOT inside the app.

```mermaid
sequenceDiagram
    participant OS as Android/iOS System
    participant Native as Plugin Native Layer
    participant HT as Headless Task (Dart Isolate)
    participant API as Backend API
    participant Notif as Local Notifications

    Note over OS, Native: App is Killed
    OS->>Native: OS Detects Geofence (ENTER/EXIT)
    Native->>HT: Launch Headless Runner
    
    Note over HT: No UI Context Available
    
    alt On GEOFENCE ENTER
        HT->>HT: Identify Station ID
        HT->>API: Call Arrival API (/api/trip/arrival)
        HT->>Notif: "You have ARRIVED at [Station Name]"
    else On GEOFENCE EXIT
        HT->>HT: Identify Station ID
        HT->>API: Call Depart API (/api/trip/depart)
        HT->>Notif: "You have DEPARTED from [Station Name]"
    end
```

### B. Headless Ride State Management (Stop/Resume)
How the tracking lifecycle finishes or persists across phone reboots in a killed state.

```mermaid
sequenceDiagram
    participant OS as Android/iOS System
    participant Native as Plugin Native Layer
    participant HT as Headless Task (Dart Isolate)
    participant API as Backend API

    Note over OS, Native: Trip is active in Background
    
    alt Scenario: Auto Stop on Final Destination
        Native->>HT: Final Geofence ENTER
        HT->>API: Call End Trip API (/api/trip/complete)
        HT->>Native: BackgroundGeolocation.stop()
        Note over Native: Hardware GPS Off
    end

    alt Scenario: System Reboot
        OS->>Native: BOOT_COMPLETED Event
        Native->>Native: Auto-Start (startOnBoot: true)
        Native->>HT: Trigger HT ('REBOOT')
        HT->>API: Notify Backend: Tracking Resumed after Reboot
    end
```

---

## 8. API Integration Checklist
To complete the **Auto Arrival/Depart** setup, ensure your backend implementation handles these specific endpoints:

| Event | Action Name | Logic Flow | Endpoint Example |
| :--- | :--- | :--- | :--- |
| **GEOFENCE ENTER** | Arrival | Triggered by SM -> SYNC | `/api/trip/arrival` |
| **GEOFENCE EXIT** | Depart | Triggered by SM -> SYNC | `/api/trip/depart` |
| **START RIDE** | Setup | Returns stations list | `/api/ride/start` |
| **LOCATION** | Tracking | Streamed via Sockets | `socket.emit('location')` |

---

## 7. Cleanup
Always ensure `stopTrip()` is called when the ride is finished to release the GPS hardware and close the socket listeners.

```dart
await viewModel.stopTrip();
```
