# Implementation Plan: Voxify Voice Dictation

**Branch**: `001-voice-dictation` | **Date**: 2026-01-20 | **Spec**: `/specs/001-voice-dictation/spec.md`
**Input**: Feature specification from `/specs/001-voice-dictation/spec.md`

## Summary

Build a macOS-only, offline-first dictation app that matches Typeless-level
intelligence: real-time speech-to-text with polishing, context-aware tone,
voice-command edits, multilingual support, and system-wide insertion. The plan
implements Swift/SwiftUI UI with AVFoundation capture, whisper.cpp for local
STT, MLX local LLM polishing with optional user-key cloud fallbacks, and
Accessibility-based text insertion.

## Technical Context

**Language/Version**: Swift 5.9+  
**Primary Dependencies**: SwiftUI, AVFoundation, whisper.cpp (Swift package),
MLX, AXSwift (or custom Accessibility wrapper), HotKey (or native hotkey),
Swift Package Manager  
**Storage**: UserDefaults + local JSON files (settings, dictionary, keys)  
**Testing**: XCTest (unit + integration)  
**Target Platform**: macOS 13+ (Apple Silicon primary)  
**Project Type**: Single desktop app  
**Performance Goals**: <800ms short-phrase latency, <200ms preview updates,
60fps UI  
**Constraints**: Offline-first, zero data retention, explicit opt-in for any
cloud processing, low CPU/memory on M1/M2  
**Scale/Scope**: Single-user local app, system-wide dictation across macOS apps

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Privacy: offline-first, no retention, user-consented API usage only
- [x] Open source: MIT license and contribution posture preserved
- [x] macOS-native: Swift/SwiftUI + HIG compliance and accessibility plan
- [x] Testing: unit + integration coverage for critical paths (>= 80%)
- [x] Performance: <800ms short-phrase latency and 60fps UI budget defined
- [x] UX consistency: cross-app behavior and error handling defined
- [x] Inclusivity: language coverage and accent support plan documented

## Project Structure

### Documentation (this feature)

```text
specs/001-voice-dictation/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
Voxify/
├── Voxify.xcodeproj/
├── Voxify/
│   ├── App/
│   ├── UI/
│   ├── Features/
│   ├── Services/
│   ├── Models/
│   ├── Resources/
│   └── Supporting/
├── Packages/
│   ├── AudioEngine/
│   ├── STTService/
│   ├── PolishingService/
│   ├── ContextDetector/
│   ├── TextInserter/
│   └── Shared/
└── Tests/
    ├── Unit/
    └── Integration/
```

**Structure Decision**: Single macOS app with internal Swift packages for core
services, enabling clear MVVM separation and testable modules while keeping
Swift Package Manager as the only dependency manager.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| N/A | N/A | N/A |
