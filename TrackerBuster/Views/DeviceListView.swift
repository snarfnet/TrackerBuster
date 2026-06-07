import SwiftUI

struct DeviceListView: View {
    @EnvironmentObject var scanner: BLEScanner

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                if scanner.detectedDevices.isEmpty {
                    emptyState
                } else {
                    deviceList
                }
            }
            .navigationTitle("検出デバイス")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "antenna.radiowaves.left.and.right.slash")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            Text("デバイス未検出")
                .font(.headline)
                .foregroundColor(.gray)
            Text("スキャンを開始すると\n近くのトラッカーが表示されます")
                .font(.caption)
                .foregroundColor(.gray.opacity(0.7))
                .multilineTextAlignment(.center)
        }
    }

    private var deviceList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(scanner.detectedDevices) { device in
                    NavigationLink(destination: DeviceDetailView(device: device)) {
                        DeviceRow(device: device)
                    }
                }
            }
            .padding()
            .padding(.bottom, 60) // Ad space
        }
    }
}

struct DeviceRow: View {
    let device: TrackerDevice

    var body: some View {
        HStack(spacing: 14) {
            // Type icon
            ZStack {
                Circle()
                    .fill(threatColor.opacity(0.15))
                    .frame(width: 48, height: 48)
                Image(systemName: device.type.icon)
                    .font(.title3)
                    .foregroundColor(threatColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(device.name ?? device.type.description)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .lineLimit(1)

                    if device.isSuspicious {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption2)
                            .foregroundColor(.red)
                    }
                }

                HStack(spacing: 8) {
                    Label(device.type.rawValue, systemImage: "tag")
                    Label(device.durationText, systemImage: "clock")
                }
                .font(.caption2)
                .foregroundColor(.gray)
            }

            Spacer()

            // RSSI signal strength
            VStack(alignment: .trailing, spacing: 4) {
                SignalStrengthView(rssi: device.rssi)
                Text("\(device.rssi) dBm")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            device.isSuspicious ? Color.red.opacity(0.5) : Color.clear,
                            lineWidth: 1
                        )
                )
        )
    }

    private var threatColor: Color {
        switch device.threatLevel {
        case .high: return .red
        case .medium: return .orange
        case .low: return Color("accentRed")
        }
    }
}

struct SignalStrengthView: View {
    let rssi: Int

    private var bars: Int {
        if rssi >= -50 { return 4 }
        if rssi >= -60 { return 3 }
        if rssi >= -70 { return 2 }
        return 1
    }

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<4, id: \.self) { i in
                RoundedRectangle(cornerRadius: 1)
                    .fill(i < bars ? Color("accentRed") : Color.gray.opacity(0.3))
                    .frame(width: 4, height: CGFloat(6 + i * 4))
            }
        }
    }
}
