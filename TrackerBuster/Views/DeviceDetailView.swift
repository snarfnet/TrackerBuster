import SwiftUI
import MapKit

struct DeviceDetailView: View {
    let device: TrackerDevice

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    headerCard

                    // Info grid
                    infoGrid

                    // Map
                    if !device.locations.isEmpty {
                        mapSection
                    }

                    // Safety tips
                    safetyTips

                    Spacer().frame(height: 60)
                }
                .padding()
            }
        }
        .navigationTitle(device.name ?? device.type.description)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(Color.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    private var headerCard: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(threatGradient)
                    .frame(width: 80, height: 80)
                Image(systemName: device.type.icon)
                    .font(.largeTitle)
                    .foregroundColor(.white)
            }

            Text(device.type.description)
                .font(.headline)
                .foregroundColor(.white)

            HStack(spacing: 20) {
                threatBadge
                Text("検出回数: \(device.seenCount)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.06))
        )
    }

    private var threatBadge: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(threatColor)
                .frame(width: 8, height: 8)
            Text("脅威レベル: \(device.threatLevel.rawValue)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(threatColor)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(threatColor.opacity(0.15))
        )
    }

    private var infoGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            infoCard(title: "信号強度", value: "\(device.rssi) dBm", icon: "wifi")
            infoCard(title: "検出時間", value: device.durationText, icon: "clock")
            infoCard(title: "初回検出", value: timeString(device.firstSeen), icon: "calendar")
            infoCard(title: "最終検出", value: timeString(device.lastSeen), icon: "clock.arrow.circlepath")
        }
    }

    private func infoCard(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(Color("accentRed"))
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            Text(title)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.06))
        )
    }

    private var mapSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("検出場所")
                .font(.headline)
                .foregroundColor(.white)

            Map {
                ForEach(Array(device.locations.enumerated()), id: \.offset) { index, location in
                    Marker("", coordinate: location)
                        .tint(index == device.locations.count - 1 ? .red : Color("accentRed"))
                }
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    private var safetyTips: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("安全のヒント")
                .font(.headline)
                .foregroundColor(.white)

            tipRow(icon: "magnifyingglass", text: "カバンや車の下を確認してください")
            tipRow(icon: "phone.fill", text: "身の危険を感じたら110番に連絡")
            tipRow(icon: "person.2.fill", text: "人通りの多い場所へ移動してください")
            tipRow(icon: "location.slash.fill", text: "見つけたトラッカーのバッテリーを外す")
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.06))
        )
    }

    private func tipRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(Color("accentRed"))
                .frame(width: 20)
            Text(text)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }

    private func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }

    private var threatColor: Color {
        switch device.threatLevel {
        case .high: return .red
        case .medium: return .orange
        case .low: return Color("accentRed")
        }
    }

    private var threatGradient: LinearGradient {
        LinearGradient(
            colors: [threatColor, threatColor.opacity(0.5)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
