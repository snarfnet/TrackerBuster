import SwiftUI

struct ScanView: View {
    @EnvironmentObject var scanner: BLEScanner
    @State private var pulseAnimation = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 30) {
                    Spacer()

                    // Status indicator
                    statusView

                    // Scan button
                    scanButton

                    // Quick stats
                    statsBar

                    Spacer()
                    Spacer().frame(height: 60) // Ad space
                }
            }
            .navigationTitle("トラッカーバスター")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    private var statusView: some View {
        ZStack {
            // Pulse rings
            if scanner.isScanning {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .stroke(
                            scanner.suspiciousCount > 0
                                ? Color.red.opacity(0.3)
                                : Color("accentRed").opacity(0.3),
                            lineWidth: 2
                        )
                        .frame(width: 200 + CGFloat(i * 40), height: 200 + CGFloat(i * 40))
                        .scaleEffect(pulseAnimation ? 1.2 : 0.8)
                        .opacity(pulseAnimation ? 0 : 0.7)
                        .animation(
                            .easeInOut(duration: 2)
                                .repeatForever(autoreverses: false)
                                .delay(Double(i) * 0.5),
                            value: pulseAnimation
                        )
                }
            }

            // Center circle
            Circle()
                .fill(
                    RadialGradient(
                        colors: statusColors,
                        center: .center,
                        startRadius: 10,
                        endRadius: 80
                    )
                )
                .frame(width: 160, height: 160)
                .shadow(color: statusColors.first?.opacity(0.5) ?? .clear, radius: 20)

            VStack(spacing: 8) {
                Image(systemName: statusIcon)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)

                Text(statusText)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
    }

    private var scanButton: some View {
        Button {
            if scanner.isScanning {
                scanner.stopScanning()
                pulseAnimation = false
            } else {
                scanner.startScanning()
                pulseAnimation = true
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: scanner.isScanning ? "stop.fill" : "play.fill")
                Text(scanner.isScanning ? "スキャン停止" : "スキャン開始")
                    .fontWeight(.bold)
            }
            .font(.title3)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(scanner.isScanning ? Color.gray : Color("accentRed"))
            )
        }
        .padding(.horizontal, 40)
        .disabled(scanner.bluetoothState != .poweredOn)
    }

    private var statsBar: some View {
        HStack(spacing: 0) {
            statItem(
                title: "検出数",
                value: "\(scanner.detectedDevices.count)",
                icon: "antenna.radiowaves.left.and.right"
            )
            Divider()
                .frame(height: 40)
                .background(Color.gray.opacity(0.5))
            statItem(
                title: "不審",
                value: "\(scanner.suspiciousCount)",
                icon: "exclamationmark.triangle.fill"
            )
            Divider()
                .frame(height: 40)
                .background(Color.gray.opacity(0.5))
            statItem(
                title: "Bluetooth",
                value: bluetoothStatusText,
                icon: "bolt.fill"
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
        )
        .padding(.horizontal, 20)
    }

    private func statItem(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(Color("accentRed"))
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text(title)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Computed

    private var statusColors: [Color] {
        if !scanner.isScanning {
            return [Color.gray, Color.gray.opacity(0.5)]
        }
        if scanner.suspiciousCount > 0 {
            return [Color.red, Color.red.opacity(0.5)]
        }
        return [Color("accentRed"), Color("accentRed").opacity(0.5)]
    }

    private var statusIcon: String {
        if !scanner.isScanning { return "shield.slash" }
        if scanner.suspiciousCount > 0 { return "exclamationmark.shield.fill" }
        return "shield.checkered"
    }

    private var statusText: String {
        if scanner.bluetoothState != .poweredOn { return "BTオフ" }
        if !scanner.isScanning { return "待機中" }
        if scanner.suspiciousCount > 0 { return "警告!" }
        return "監視中"
    }

    private var bluetoothStatusText: String {
        switch scanner.bluetoothState {
        case .poweredOn: return "ON"
        case .poweredOff: return "OFF"
        default: return "---"
        }
    }
}
