import SwiftUI

/// A visual representation of audio levels as an animated waveform
/// Similar to Typeless's visual feedback when recording
struct AudioWaveformView: View {
    let audioLevels: [Float]
    let isActive: Bool

    /// Number of bars in the waveform
    private let barCount = 30

    /// Spacing between bars
    private let barSpacing: CGFloat = 2

    /// Maximum bar height
    private let maxHeight: CGFloat = 40

    /// Bar corner radius
    private let cornerRadius: CGFloat = 2

    var body: some View {
        HStack(alignment: .center, spacing: barSpacing) {
            ForEach(0..<barCount, id: \.self) { index in
                WaveformBar(
                    level: level(at: index),
                    isActive: isActive,
                    maxHeight: maxHeight,
                    cornerRadius: cornerRadius,
                    index: index
                )
            }
        }
        .frame(height: maxHeight)
    }

    private func level(at index: Int) -> Float {
        guard index < audioLevels.count else { return 0 }
        return audioLevels[index]
    }
}

/// Individual bar in the waveform
struct WaveformBar: View {
    let level: Float
    let isActive: Bool
    let maxHeight: CGFloat
    let cornerRadius: CGFloat
    let index: Int

    @State private var animatedLevel: CGFloat = 0

    private var targetHeight: CGFloat {
        if !isActive { return 4 }
        let minHeight: CGFloat = 4
        return max(minHeight, CGFloat(level) * maxHeight)
    }

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(barColor)
            .frame(width: 3, height: animatedLevel)
            .animation(
                .spring(response: 0.15, dampingFraction: 0.6),
                value: animatedLevel
            )
            .onAppear {
                animatedLevel = targetHeight
            }
            .onChange(of: level) { _ in
                animatedLevel = targetHeight
            }
            .onChange(of: isActive) { _ in
                if !isActive {
                    animatedLevel = 4
                }
            }
    }

    private var barColor: Color {
        if !isActive {
            return Color.secondary.opacity(0.3)
        }

        // Gradient from blue to purple based on level
        let intensity = Double(level)
        return Color(
            hue: 0.6 - (intensity * 0.1), // Blue to purple
            saturation: 0.7 + (intensity * 0.3),
            brightness: 0.8 + (intensity * 0.2)
        )
    }
}

/// Compact waveform indicator for minimal UI
struct CompactWaveformIndicator: View {
    let audioLevel: Float
    let isActive: Bool

    @State private var scale: CGFloat = 1.0

    var body: some View {
        ZStack {
            // Outer ring (pulsing when active)
            Circle()
                .stroke(isActive ? Color.accentColor : Color.secondary.opacity(0.3), lineWidth: 2)
                .frame(width: 32, height: 32)
                .scaleEffect(isActive ? scale : 1.0)

            // Inner circle (shows audio level)
            Circle()
                .fill(isActive ? Color.accentColor : Color.secondary.opacity(0.3))
                .frame(width: innerSize, height: innerSize)

            // Microphone icon
            Image(systemName: isActive ? "waveform" : "mic.fill")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
        }
        .onChange(of: isActive) { active in
            if active {
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    scale = 1.1
                }
            } else {
                withAnimation(.easeOut(duration: 0.2)) {
                    scale = 1.0
                }
            }
        }
        .onAppear {
            if isActive {
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    scale = 1.1
                }
            }
        }
    }

    private var innerSize: CGFloat {
        if !isActive { return 20 }
        return 16 + CGFloat(audioLevel) * 8
    }
}

/// Animated dots indicator (alternative minimal design)
struct PulsingDotsIndicator: View {
    let isActive: Bool
    let audioLevel: Float

    @State private var animationPhase: Double = 0

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(isActive ? Color.accentColor : Color.secondary.opacity(0.3))
                    .frame(width: dotSize(for: index), height: dotSize(for: index))
                    .animation(
                        .easeInOut(duration: 0.3).delay(Double(index) * 0.1),
                        value: audioLevel
                    )
            }
        }
        .onAppear {
            if isActive {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    animationPhase = 1
                }
            }
        }
    }

    private func dotSize(for index: Int) -> CGFloat {
        if !isActive { return 6 }
        let baseSize: CGFloat = 6
        let levelBoost = CGFloat(audioLevel) * 4
        let phaseOffset = sin((animationPhase * .pi * 2) + (Double(index) * .pi / 1.5))
        return baseSize + levelBoost + CGFloat(phaseOffset) * 2
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("Waveform Views")
            .font(.headline)

        AudioWaveformView(
            audioLevels: (0..<30).map { _ in Float.random(in: 0...1) },
            isActive: true
        )

        HStack(spacing: 20) {
            CompactWaveformIndicator(audioLevel: 0.5, isActive: true)
            CompactWaveformIndicator(audioLevel: 0.2, isActive: false)
        }

        PulsingDotsIndicator(isActive: true, audioLevel: 0.6)
    }
    .padding()
    .frame(width: 400)
}
