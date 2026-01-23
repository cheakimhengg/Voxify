import SwiftUI

/// Settings view wrapper for dashboard context
struct DashboardSettingsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Settings")
                        .font(.system(size: 28, weight: .bold))

                    Text("Configure Voxify to work the way you want.")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }

                // Embed the existing GeneralSettingsView
                GeneralSettingsView()
                    .background(Color(NSColor.controlBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(24)
        }
    }
}

#Preview {
    DashboardSettingsView()
        .frame(width: 700, height: 600)
}
