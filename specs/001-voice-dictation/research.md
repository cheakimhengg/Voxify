# Phase 0 Research: Voxify Voice Dictation

## Decisions

### Decision: macOS 13+ baseline (Apple Silicon primary)
**Rationale**: Aligns with MLX and modern SwiftUI/AVFoundation capabilities
without legacy workarounds. Ensures performance targets and accessibility APIs.
**Alternatives considered**: macOS 12; dropped due to weaker MLX support.

### Decision: Local-first STT with whisper.cpp Swift package
**Rationale**: Enables offline processing and privacy guarantees while meeting
low-latency needs. Community wrappers reduce integration risk.
**Alternatives considered**: Apple Speech-only; cloud-only STT; rejected due to
privacy and offline-first requirements.

### Decision: Local LLM polishing via MLX with quantized Phi-3 Mini / Llama-3.1 8B
**Rationale**: On-device inference on Apple Silicon meets privacy and latency
constraints while supporting high-quality polishing.
**Alternatives considered**: Cloud-only LLMs; rejected for privacy and cost.

### Decision: Optional cloud fallbacks via user-provided keys
**Rationale**: Provides user choice for quality/coverage without violating
privacy or free access constraints.
**Alternatives considered**: Built-in server proxy; rejected due to data
retention and operational overhead.

### Decision: Accessibility-based text insertion (AXSwift or custom wrapper)
**Rationale**: Required for system-wide insertion into any focused field.
**Alternatives considered**: Clipboard-only insertion; rejected as inferior UX.

### Decision: Context detection via active app bundle ID
**Rationale**: Deterministic, low-latency signal for tone adaptation.
**Alternatives considered**: UI content analysis; rejected for privacy and risk.

### Decision: Global hotkey + menu bar control
**Rationale**: Ensures consistent access across apps and workflows.
**Alternatives considered**: Hotkey only; menu bar only; rejected as limiting.

### Decision: Ephemeral live preview text
**Rationale**: Aligns with zero-retention privacy principles and reduces risk of
leaking sensitive content.
**Alternatives considered**: Session history; rejected for privacy.

### Decision: Swift Package Manager only
**Rationale**: Keeps dependency management native and reproducible.
**Alternatives considered**: CocoaPods, Carthage; rejected for simplicity.
