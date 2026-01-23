import SwiftUI

/// Sidebar navigation for the dashboard
struct SidebarView: View {
    @Binding var selectedItem: NavigationItem
    @Binding var showSettings: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // App branding
            brandingHeader

            Divider()
                .padding(.horizontal, 16)

            // Navigation items
            VStack(spacing: 4) {
                ForEach(NavigationItem.allCases) { item in
                    NavigationRow(
                        item: item,
                        isSelected: selectedItem == item
                    ) {
                        selectedItem = item
                    }
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 8)

            Spacer()

            // Footer with settings button
            footerSection
        }
        .background(Color(NSColor.windowBackgroundColor))
    }

    // MARK: - Branding Header

    private var brandingHeader: some View {
        HStack(spacing: 10) {
            Image(systemName: "waveform.circle.fill")
                .font(.system(size: 28))
                .foregroundStyle(.linearGradient(
                    colors: [.blue, .purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))

            VStack(alignment: .leading, spacing: 2) {
                Text("Voxify")
                    .font(.system(size: 16, weight: .semibold))
                Text("Voice Dictation")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
    }

    // MARK: - Footer Section

    private var footerSection: some View {
        VStack(spacing: 8) {
            Divider()
                .padding(.horizontal, 16)

            // Settings button
            Button(action: { showSettings = true }) {
                HStack(spacing: 10) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 14))
                        .frame(width: 20)

                    Text("Settings")
                        .font(.system(size: 13))

                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .foregroundColor(.primary)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 8)

            // Version info
            HStack {
                Text("v1.0.0")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                Spacer()
                Text("Open Source")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
    }
}

// MARK: - Navigation Row

private struct NavigationRow: View {
    let item: NavigationItem
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: isSelected ? item.selectedIcon : item.icon)
                    .font(.system(size: 14))
                    .frame(width: 20)

                Text(item.title)
                    .font(.system(size: 13))

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.accentColor.opacity(0.15) : Color.clear)
            )
            .foregroundColor(isSelected ? .accentColor : .primary)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SidebarView(selectedItem: .constant(.home), showSettings: .constant(false))
        .frame(width: 200, height: 500)
}
