import AppKit
import SwiftUI

/// A floating panel that shows recording status - appears when dictation starts
final class RecordingPopupWindow: NSPanel {
    private var hostingView: NSHostingView<RecordingPopupContent>?

    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 280, height: 80),
            styleMask: [.nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        isFloatingPanel = true
        level = .floating
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true
        isMovableByWindowBackground = true

        let content = RecordingPopupContent()
        let hostingView = NSHostingView(rootView: content)
        hostingView.frame = contentView?.bounds ?? .zero
        hostingView.autoresizingMask = [.width, .height]
        contentView?.addSubview(hostingView)
        self.hostingView = hostingView
    }

    func update(isRecording: Bool, text: String, mode: String) {
        let content = RecordingPopupContent(isRecording: isRecording, text: text, mode: mode)
        hostingView?.rootView = content
    }

    func showAtCenter() {
        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.visibleFrame
        let x = screenFrame.midX - frame.width / 2
        let y = screenFrame.maxY - 120
        setFrameOrigin(NSPoint(x: x, y: y))
        orderFrontRegardless()
    }

    func dismiss() {
        orderOut(nil)
    }
}

/// The SwiftUI content for the recording popup
struct RecordingPopupContent: View {
    var isRecording: Bool = true
    var text: String = ""
    var mode: String = "Hold"

    @State private var pulseAnimation = false
    @State private var language: String = SettingsStore().load().interfaceLanguage

    private var isKhmer: Bool { language == "Khmer" }

    var body: some View {
        HStack(spacing: 12) {
            // Recording indicator
            Circle()
                .fill(isRecording ? Color.red : Color.gray)
                .frame(width: 12, height: 12)
                .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: pulseAnimation)
                .onAppear { pulseAnimation = isRecording }
                .onChange(of: isRecording) { newValue in
                    pulseAnimation = newValue
                }

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(isRecording
                         ? (isKhmer ? "កំពុងថត..." : "Recording...")
                         : (isKhmer ? "កំពុងដំណើរការ" : "Processing"))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.primary)

                    Spacer()

                    Text(localizedMode)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.15))
                        .clipShape(Capsule())
                }

                if text.isEmpty {
                    Text(isKhmer ? "និយាយឥឡូវ..." : "Speak now...")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                } else {
                    Text(text)
                        .font(.system(size: 12))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(width: 280)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.windowBackgroundColor))
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)
        )
        .onReceive(NotificationCenter.default.publisher(for: .voxifySettingsDidChange)) { _ in
            language = SettingsStore().load().interfaceLanguage
        }
    }

    private var localizedMode: String {
        if isKhmer {
            switch mode {
            case "Hold": return "សង្កត់"
            case "Free Hand": return "ស្វ័យប្រវត្តិ"
            default: return mode
            }
        }
        return mode
    }
}
