import SwiftUI
import Carbon.HIToolbox

/// A view that captures keyboard shortcuts when focused
struct KeyCaptureButton: View {
    @Binding var hotkeyConfig: HotkeyConfig
    @State private var isCapturing = false
    @State private var localMonitor: Any?
    @State private var globalMonitor: Any?
    @State private var tempConfig: HotkeyConfig?

    var body: some View {
        Button(action: {
            if isCapturing {
                stopCapturing(save: false)
            } else {
                startCapturing()
            }
        }) {
            HStack(spacing: 4) {
                if isCapturing {
                    Text("Press any key...")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.accentColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.accentColor.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.accentColor, lineWidth: 1)
                        )
                } else {
                    // Show readable string as single badge
                    Text(hotkeyConfig.readableString.isEmpty ? "Click to set" : hotkeyConfig.readableString)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color(NSColor.separatorColor).opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 6))

                    Image(systemName: "keyboard")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }
        }
        .buttonStyle(.plain)
        .onDisappear {
            stopCapturing(save: false)
        }
    }

    private func startCapturing() {
        isCapturing = true
        tempConfig = nil

        // Local monitor for when app is focused
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .flagsChanged]) { event in
            self.handleEvent(event)
            return nil // Consume the event
        }

        // Global monitor for when app is not focused
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.keyDown, .flagsChanged]) { event in
            self.handleEvent(event)
        }
    }

    private func stopCapturing(save: Bool) {
        isCapturing = false

        if let localMonitor {
            NSEvent.removeMonitor(localMonitor)
        }
        if let globalMonitor {
            NSEvent.removeMonitor(globalMonitor)
        }
        localMonitor = nil
        globalMonitor = nil

        // Save the temp config if we have one
        if save, let config = tempConfig {
            hotkeyConfig = config
        }
        tempConfig = nil
    }

    private func handleEvent(_ event: NSEvent) {
        var modifiers: [String] = []
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)

        if flags.contains(.control) { modifiers.append("control") }
        if flags.contains(.option) { modifiers.append("option") }
        if flags.contains(.shift) { modifiers.append("shift") }
        if flags.contains(.command) { modifiers.append("command") }

        // For key down events, capture the key immediately
        if event.type == .keyDown {
            let keyCode = event.keyCode
            let keyChar = keyCharacter(for: keyCode, event: event)

            // Escape key cancels capture
            if keyCode == UInt16(kVK_Escape) {
                stopCapturing(save: false)
                return
            }

            // Save immediately - can be just a single key (like F1) or modifier+key
            hotkeyConfig = HotkeyConfig(
                modifiers: modifiers,
                keyCode: keyCode,
                keyChar: keyChar
            )
            stopCapturing(save: false)
        } else if event.type == .flagsChanged {
            // For modifier-only shortcuts
            if modifiers.isEmpty {
                // All modifiers released - save what we captured
                if tempConfig != nil {
                    stopCapturing(save: true)
                }
            } else {
                // Store current modifiers as temp config
                tempConfig = HotkeyConfig(
                    modifiers: modifiers,
                    keyCode: nil,
                    keyChar: nil
                )
            }
        }
    }

    private func keyCharacter(for keyCode: UInt16, event: NSEvent) -> String? {
        // Map common key codes to characters
        switch Int(keyCode) {
        case kVK_Space: return "Space"
        case kVK_Return: return "Return"
        case kVK_Tab: return "Tab"
        case kVK_Delete: return "Delete"
        case kVK_ForwardDelete: return "FwdDel"
        case kVK_UpArrow: return "Up"
        case kVK_DownArrow: return "Down"
        case kVK_LeftArrow: return "Left"
        case kVK_RightArrow: return "Right"
        case kVK_Home: return "Home"
        case kVK_End: return "End"
        case kVK_PageUp: return "PgUp"
        case kVK_PageDown: return "PgDn"
        case kVK_F1: return "F1"
        case kVK_F2: return "F2"
        case kVK_F3: return "F3"
        case kVK_F4: return "F4"
        case kVK_F5: return "F5"
        case kVK_F6: return "F6"
        case kVK_F7: return "F7"
        case kVK_F8: return "F8"
        case kVK_F9: return "F9"
        case kVK_F10: return "F10"
        case kVK_F11: return "F11"
        case kVK_F12: return "F12"
        default:
            // Use the characters from the event
            if let chars = event.charactersIgnoringModifiers, !chars.isEmpty {
                return chars.uppercased()
            }
            return nil
        }
    }
}

/// A row view for editing hotkey shortcuts with key capture
struct HotkeySettingsRow: View {
    let title: String
    let description: String
    @Binding var hotkeyConfig: HotkeyConfig

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))

                Text(description)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }

            Spacer()

            KeyCaptureButton(hotkeyConfig: $hotkeyConfig)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        HotkeySettingsRow(
            title: "Hold to Talk",
            description: "Hold down to speak",
            hotkeyConfig: .constant(.defaultHoldToTalk)
        )

        HotkeySettingsRow(
            title: "Hands-free Mode",
            description: "Toggle continuous mode",
            hotkeyConfig: .constant(.defaultHandsFree)
        )
    }
    .padding()
    .frame(width: 400)
}
