import Foundation
import CoreBluetooth
import CoreLocation
import Combine

class BLEScanner: NSObject, ObservableObject {
    @Published var detectedDevices: [TrackerDevice] = []
    @Published var isScanning = false
    @Published var bluetoothState: CBManagerState = .unknown
    @Published var suspiciousCount: Int = 0

    private var centralManager: CBCentralManager?
    private var locationManager: CLLocationManager?
    private var currentLocation: CLLocationCoordinate2D?
    private var cleanupTimer: Timer?

    // Settings
    @Published var suspiciousThresholdMinutes: Double = 10
    @Published var alertEnabled: Bool = true

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: .main)
        setupLocationManager()
    }

    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.startUpdatingLocation()
    }

    func startScanning() {
        guard let central = centralManager, central.state == .poweredOn else { return }

        let serviceUUIDs: [CBUUID] = [
            CBUUID(string: "7DFC9000-7D1C-4951-86AA-8D9728F8D66C"), // Find My
            CBUUID(string: "FEED"),  // Tile
            CBUUID(string: "FEEC"),  // Tile alt
        ]

        // Scan for all BLE devices to catch trackers
        central.scanForPeripherals(
            withServices: nil,
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: true]
        )
        isScanning = true

        // Cleanup old devices every 30 seconds
        cleanupTimer?.invalidate()
        cleanupTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.cleanupOldDevices()
            self?.evaluateThreats()
        }
    }

    func stopScanning() {
        centralManager?.stopScan()
        isScanning = false
        cleanupTimer?.invalidate()
        cleanupTimer = nil
    }

    private func cleanupOldDevices() {
        let cutoff = Date().addingTimeInterval(-300) // 5 minutes
        detectedDevices.removeAll { $0.lastSeen < cutoff }
    }

    private func evaluateThreats() {
        let thresholdSeconds = suspiciousThresholdMinutes * 60
        var newSuspiciousCount = 0

        for i in detectedDevices.indices {
            let wasSuspicious = detectedDevices[i].isSuspicious
            let isSuspicious = detectedDevices[i].durationNearby >= thresholdSeconds
                && detectedDevices[i].seenCount >= 5
            detectedDevices[i].isSuspicious = isSuspicious

            if isSuspicious {
                newSuspiciousCount += 1
                if !wasSuspicious && alertEnabled {
                    NotificationService.shared.sendTrackerAlert(device: detectedDevices[i])
                }
            }
        }
        suspiciousCount = newSuspiciousCount
    }

    private func processDiscoveredPeripheral(
        _ peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi: NSNumber
    ) {
        let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data
        let serviceUUIDs = (advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID])?.map { $0.uuidString }
        let localName = advertisementData[CBAdvertisementDataLocalNameKey] as? String

        let trackerType = TrackerType.identify(
            manufacturerData: manufacturerData,
            serviceUUIDs: serviceUUIDs
        )

        // Only track known tracker types and suspicious unknowns
        guard trackerType != .unknown || isLikelyTracker(advertisementData: advertisementData) else { return }

        let peripheralID = peripheral.identifier

        if let index = detectedDevices.firstIndex(where: { $0.peripheralIdentifier == peripheralID }) {
            // Update existing
            detectedDevices[index].rssi = rssi.intValue
            detectedDevices[index].lastSeen = Date()
            detectedDevices[index].seenCount += 1
            if let loc = currentLocation {
                detectedDevices[index].locations.append(loc)
                // Keep only last 50 locations
                if detectedDevices[index].locations.count > 50 {
                    detectedDevices[index].locations.removeFirst()
                }
            }
        } else {
            // New device
            var locations: [CLLocationCoordinate2D] = []
            if let loc = currentLocation {
                locations.append(loc)
            }

            let device = TrackerDevice(
                id: UUID(),
                peripheralIdentifier: peripheralID,
                name: localName ?? peripheral.name,
                type: trackerType,
                rssi: rssi.intValue,
                firstSeen: Date(),
                lastSeen: Date(),
                seenCount: 1,
                locations: locations,
                isSuspicious: false
            )
            detectedDevices.append(device)
        }

        // Sort: suspicious first, then by duration
        detectedDevices.sort { lhs, rhs in
            if lhs.isSuspicious != rhs.isSuspicious { return lhs.isSuspicious }
            return lhs.durationNearby > rhs.durationNearby
        }
    }

    private func isLikelyTracker(advertisementData: [String: Any]) -> Bool {
        // Check for characteristics common to tracking devices
        guard let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data else {
            return false
        }
        // Small payload + no name = likely tracker beacon
        let hasNoName = advertisementData[CBAdvertisementDataLocalNameKey] == nil
        let smallPayload = manufacturerData.count < 30
        let noServices = (advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID])?.isEmpty ?? true

        return hasNoName && smallPayload && noServices && manufacturerData.count >= 2
    }
}

// MARK: - CBCentralManagerDelegate
extension BLEScanner: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        bluetoothState = central.state
        if central.state == .poweredOn && isScanning {
            startScanning()
        }
    }

    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        guard RSSI.intValue > -90 else { return } // Ignore very weak signals
        processDiscoveredPeripheral(peripheral, advertisementData: advertisementData, rssi: RSSI)
    }
}

// MARK: - CLLocationManagerDelegate
extension BLEScanner: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last?.coordinate
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse ||
           manager.authorizationStatus == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }
}
