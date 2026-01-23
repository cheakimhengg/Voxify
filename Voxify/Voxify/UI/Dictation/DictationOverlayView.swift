import AppKit
import SwiftUI

/// Clean, minimal dictation overlay inspired by Typeless
/// Shows only essential information with smooth animations
struct DictationOverlayView: View {
    @ObservedObject var viewModel: DictationViewModel
    @State private var showRawText = false

    var body: some View {
        VStack(spacing: 0) {
            // Main content area
            VStack(spacing: 16) {
                // Status header with waveform
                statusHeader

                // Main text display
                textDisplay

                // Quick actions (only show when not active)
                if !viewModel.isActive {
                    quickActions
                }
            }
            .padding(20)

            // Error/status messages
            if let statusMessage = viewModel.statusMessage {
                statusBanner(message: statusMessage, isError: true)
            }

            // No focus popup
            if let noFocusText = viewModel.noFocusText {
                noFocusSection(text: noFocusText)
            }
        }
        .frame(width: 380)
        .background(Color(NSColor.windowBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
    }

    // MARK: - Status Header

    private var statusHeader: some View {
        HStack(spacing: 12) {
            // Recording indicator
            CompactWaveformIndicator(
                audioLevel: viewModel.audioLevel,
                isActive: viewModel.isActive
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(statusTitle)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)

                Text(statusSubtitle)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Mode badge
            modeBadge
        }
    }

    private var statusTitle: String {
        if viewModel.isActive {
            return "Listening..."
        } else if !viewModel.polishedText.isEmpty {
            return "Done"
        } else {
            return "Ready"
        }
    }

    private var statusSubtitle: String {
        if viewModel.isActive {
            let wordCount = viewModel.polishedText.split(separator: " ").count
            return wordCount > 0 ? "\(wordCount) words" : "Speak now"
        } else {
            return "Press hotkey to start"
        }
    }

    private var modeBadge: some View {
        Text(viewModel.mode == .continuous ? "Continuous" : "Hold")
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(.secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.secondary.opacity(0.1))
            .clipShape(Capsule())
    }

    // MARK: - Text Display

    private var textDisplay: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Audio waveform (when active)
            if viewModel.isActive {
                AudioWaveformView(
                    audioLevels: viewModel.audioLevelHistory,
                    isActive: viewModel.isActive
                )
                .frame(height: 40)
                .padding(.vertical, 8)
            }

            // Main polished text
            if !viewModel.polishedText.isEmpty || viewModel.isActive {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.polishedText.isEmpty ? "..." : viewModel.polishedText)
                        .font(.system(size: 15))
                        .foregroundColor(.primary)
                        .lineLimit(5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .animation(.easeOut(duration: 0.15), value: viewModel.polishedText)

                    // Show raw text toggle (when there's a difference)
                    if hasPolishingDifference {
                        rawTextToggle
                    }
                }
                .padding(12)
                .background(Color(NSColor.controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                // Empty state
                emptyState
            }
        }
    }

    private var hasPolishingDifference: Bool {
        !viewModel.rawText.isEmpty &&
        !viewModel.polishedText.isEmpty &&
        viewModel.rawText != viewModel.polishedText
    }

    private var rawTextToggle: some View {
        VStack(alignment: .leading, spacing: 4) {
            Button(action: { withAnimation { showRawText.toggle() } }) {
                HStack(spacing: 4) {
                    Image(systemName: showRawText ? "chevron.down" : "chevron.right")
                        .font(.system(size: 9, weight: .semibold))
                    Text("Original")
                        .font(.system(size: 11))
                }
                .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)

            if showRawText {
                Text(viewModel.rawText)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "mic.fill")
                .font(.system(size: 28))
                .foregroundColor(.secondary.opacity(0.5))

            Text("Hold your hotkey and start speaking")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    // MARK: - Quick Actions

    private var quickActions: some View {
        HStack(spacing: 10) {
            ActionButton(
                title: "Hold to Speak",
                icon: "mic.fill",
                isPrimary: true
            ) {}
            .onLongPressGesture(minimumDuration: 0.01, maximumDistance: 50, pressing: { isPressing in
                if isPressing {
                    viewModel.start(mode: .holdToTalk)
                } else {
                    viewModel.stop()
                }
            }, perform: {})

            ActionButton(
                title: viewModel.mode == .continuous ? "Stop" : "Continuous",
                icon: viewModel.mode == .continuous ? "stop.fill" : "play.fill",
                isPrimary: false
            ) {
                viewModel.toggleContinuous()
            }
        }
    }

    // MARK: - Status Banner

    private func statusBanner(message: String, isError: Bool) -> some View {
        HStack(spacing: 8) {
            Image(systemName: isError ? "exclamationmark.triangle.fill" : "info.circle.fill")
                .font(.system(size: 12))
            Text(message)
                .font(.system(size: 12))
        }
        .foregroundColor(isError ? .red : .secondary)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(isError ? Color.red.opacity(0.1) : Color.secondary.opacity(0.1))
    }

    // MARK: - No Focus Section

    private func noFocusSection(text: String) -> some View {
        VStack(spacing: 12) {
            Divider()

            VStack(spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.orange)
                    Text("No text field detected")
                        .font(.system(size: 12, weight: .medium))
                }

                Text(text)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .background(Color(NSColor.controlBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                HStack(spacing: 10) {
                    Button(action: {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(text, forType: .string)
                        viewModel.clearNoFocus()
                    }) {
                        Label("Copy", systemImage: "doc.on.doc")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)

                    Button("Dismiss") {
                        viewModel.clearNoFocus()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
            .padding(16)
        }
    }
}

// MARK: - Action Button

private struct ActionButton: View {
    let title: String
    let icon: String
    let isPrimary: Bool
    let action: () -> Void

    var body: some View {
        if isPrimary {
            primaryButton
        } else {
            secondaryButton
        }
    }

    private var primaryButton: some View {
        Button(action: action) {
            buttonContent
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.regular)
    }

    private var secondaryButton: some View {
        Button(action: action) {
            buttonContent
        }
        .buttonStyle(.bordered)
        .controlSize(.regular)
    }

    private var buttonContent: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
            Text(title)
                .font(.system(size: 12, weight: .medium))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    DictationOverlayView(viewModel: DictationViewModel())
        .padding()
}
