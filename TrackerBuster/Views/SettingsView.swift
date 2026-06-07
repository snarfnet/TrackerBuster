import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var scanner: BLEScanner

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // Alert settings
                        settingsSection(title: "アラート設定") {
                            toggleRow(
                                title: "不審デバイス通知",
                                subtitle: "トラッカーが長時間検出された時に通知",
                                icon: "bell.fill",
                                isOn: $scanner.alertEnabled
                            )

                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "clock.fill")
                                        .foregroundColor(Color("accentRed"))
                                        .frame(width: 24)
                                    Text("警告しきい値")
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("\(Int(scanner.suspiciousThresholdMinutes))分")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color("accentRed"))
                                }

                                Slider(
                                    value: $scanner.suspiciousThresholdMinutes,
                                    in: 5...60,
                                    step: 5
                                )
                                .tint(Color("accentRed"))

                                Text("トラッカーがこの時間以上近くにいると警告")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                            .padding(14)
                        }

                        // Detection info
                        settingsSection(title: "検出対象") {
                            ForEach(TrackerType.allCases) { type in
                                HStack(spacing: 12) {
                                    Image(systemName: type.icon)
                                        .foregroundColor(Color("accentRed"))
                                        .frame(width: 24)
                                    VStack(alignment: .leading) {
                                        Text(type.description)
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                    }
                                    Spacer()
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green.opacity(0.7))
                                }
                                .padding(14)
                            }
                        }

                        // About
                        settingsSection(title: "このアプリについて") {
                            infoRow(title: "バージョン", value: "1.0.0")
                            infoRow(title: "対応OS", value: "iOS 17.0+")

                            VStack(alignment: .leading, spacing: 8) {
                                Text("免責事項")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                Text("このアプリはBLEデバイスの検出を支援しますが、すべてのトラッカーの検出を保証するものではありません。身の安全が脅かされる場合は、直ちに警察に相談してください。")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                            .padding(14)
                        }

                        Spacer().frame(height: 60)
                    }
                    .padding()
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    private func settingsSection(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
                .padding(.horizontal, 4)
                .padding(.bottom, 8)

            VStack(spacing: 1) {
                content()
            }
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(0.06))
            )
        }
    }

    private func toggleRow(title: String, subtitle: String, icon: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Color("accentRed"))
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            Spacer()
            Toggle("", isOn: isOn)
                .tint(Color("accentRed"))
                .labelsHidden()
        }
        .padding(14)
    }

    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white)
            Spacer()
            Text(value)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(14)
    }
}
