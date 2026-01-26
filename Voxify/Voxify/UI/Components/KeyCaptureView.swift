import SwiftUI
import Carbon.HIToolbox

/// A view that captures keyboard shortcuts when focused
/// User presses keys, then presses Enter to confirm or Escape to cancel
struct KeyCaptureButton: View {
    @Binding var hotkeyConfig: HotkeyConfig
    @State private var isCapturing = false
    @State private var localMonitor: Any?
    @State private var globalMonitor: Any?
    @State private var pendingConfig: HotkeyConfig?
    @State private var displayText = ""
    @State private var language: String = SettingsStore().load().interfaceLanguage

    private var isKhmer: Bool { language == "Khmer" }

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
                    VStack(alignment: .leading, spacing: 2) {
                        Text(displayText.isEmpty
                             ? (isKhmer ? "ចុចគ្រាប់ចុចណាមួយ..." : "Press any key...")
                             : displayText)
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(.accentColor)

                        Text(isKhmer ? "Enter=យល់ព្រម | Esc=បោះបង់" : "Enter=Confirm | Esc=Cancel")
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                    }
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
                    Text(hotkeyConfig.readableString.isEmpty
                         ? (isKhmer ? "ចុចដើម្បីកំណត់" : "Click to set")
                         : hotkeyConfig.readableString)
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
        .onReceive(NotificationCenter.default.publisher(for: .voxifySettingsDidChange)) { _ in
            language = SettingsStore().load().interfaceLanguage
        }
    }

    private func startCapturing() {
        isCapturing = true
        pendingConfig = nil
        displayText = ""

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

        if save, let config = pendingConfig {
            hotkeyConfig = config
            print("[KeyCapture] Saved: \(config.readableString)")
        }

        pendingConfig = nil
        displayText = ""
    }

    private func handleEvent(_ event: NSEvent) {
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)

        // Get current modifiers
        var modifiers: [String] = []
        if flags.contains(.control) { modifiers.append("control") }
        if flags.contains(.option) { modifiers.append("option") }
        if flags.contains(.shift) { modifiers.append("shift") }
        if flags.contains(.command) { modifiers.append("command") }
        if flags.contains(.function) { modifiers.append("fn") }

        if event.type == .keyDown {
            let keyCode = event.keyCode

            // Enter key confirms the current selection
            if keyCode == UInt16(kVK_Return) {
                if pendingConfig != nil {
                    stopCapturing(save: true)
                }
                return
            }

            // Escape key cancels capture
            if keyCode == UInt16(kVK_Escape) {
                stopCapturing(save: false)
                return
            }

            // Store the key configuration (modifiers + key)
            let keyChar = keyCharacter(for: keyCode, event: event)
            pendingConfig = HotkeyConfig(
                modifiers: modifiers,
                keyCode: keyCode,
                keyChar: keyChar
            )

            // Update display
            updateDisplayText()

        } else if event.type == .flagsChanged {
            // Show current modifiers being held (for modifier-only shortcuts)
            if modifiers.isEmpty {
                // All modifiers released - keep display if we have a pending config with a key
                if pendingConfig?.keyCode == nil {
                    displayText = ""
                    pendingConfig = nil
                }
            } else {
                // Update pending config for modifier-only shortcut
                // Only update if we don't have a key pressed yet
                if pendingConfig?.keyCode == nil {
                    pendingConfig = HotkeyConfig(
                        modifiers: modifiers,
                        keyCode: nil,
                        keyChar: nil
                    )
                }
                updateDisplayText()
            }
        }
    }

    private func updateDisplayText() {
        guard let config = pendingConfig else {
            displayText = ""
            return
        }
        displayText = config.readableString
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
        case kVK_F13: return "F13"
        case kVK_F14: return "F14"
        case kVK_F15: return "F15"
        case kVK_F16: return "F16"
        case kVK_F17: return "F17"
        case kVK_F18: return "F18"
        case kVK_F19: return "F19"
        case kVK_F20: return "F20"
        // Common keys
        case kVK_ANSI_A: return "A"
        case kVK_ANSI_B: return "B"
        case kVK_ANSI_C: return "C"
        case kVK_ANSI_D: return "D"
        case kVK_ANSI_E: return "E"
        case kVK_ANSI_F: return "F"
        case kVK_ANSI_G: return "G"
        case kVK_ANSI_H: return "H"
        case kVK_ANSI_I: return "I"
        case kVK_ANSI_J: return "J"
        case kVK_ANSI_K: return "K"
        case kVK_ANSI_L: return "L"
        case kVK_ANSI_M: return "M"
        case kVK_ANSI_N: return "N"
        case kVK_ANSI_O: return "O"
        case kVK_ANSI_P: return "P"
        case kVK_ANSI_Q: return "Q"
        case kVK_ANSI_R: return "R"
        case kVK_ANSI_S: return "S"
        case kVK_ANSI_T: return "T"
        case kVK_ANSI_U: return "U"
        case kVK_ANSI_V: return "V"
        case kVK_ANSI_W: return "W"
        case kVK_ANSI_X: return "X"
        case kVK_ANSI_Y: return "Y"
        case kVK_ANSI_Z: return "Z"
        case kVK_ANSI_0: return "0"
        case kVK_ANSI_1: return "1"
        case kVK_ANSI_2: return "2"
        case kVK_ANSI_3: return "3"
        case kVK_ANSI_4: return "4"
        case kVK_ANSI_5: return "5"
        case kVK_ANSI_6: return "6"
        case kVK_ANSI_7: return "7"
        case kVK_ANSI_8: return "8"
        case kVK_ANSI_9: return "9"
        case kVK_ANSI_Minus: return "-"
        case kVK_ANSI_Equal: return "="
        case kVK_ANSI_LeftBracket: return "["
        case kVK_ANSI_RightBracket: return "]"
        case kVK_ANSI_Backslash: return "\\"
        case kVK_ANSI_Semicolon: return ";"
        case kVK_ANSI_Quote: return "'"
        case kVK_ANSI_Comma: return ","
        case kVK_ANSI_Period: return "."
        case kVK_ANSI_Slash: return "/"
        case kVK_ANSI_Grave: return "`"
        default:
            // Use the characters from the event
            if let chars = event.charactersIgnoringModifiers, !chars.isEmpty {
                return chars.uppercased()
            }
            return "Key\(keyCode)"
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
