---

description: "Task list template for feature implementation"
---

# Tasks: Voxify Voice Dictation

**Input**: Design documents from `/specs/001-voice-dictation/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Tests are REQUIRED for core logic and critical paths per the constitution; only omit with explicit written justification.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [x] T001 Create Xcode project and folder scaffolding per plan in `Voxify/` (AC: project opens and builds)
- [x] T002 Add Swift Package targets for core modules in `Packages/` (AC: packages build in Xcode)
- [x] T003 [P] Configure app bundle identifiers, entitlements, and permissions in `Voxify/Voxify/App/` (AC: mic/accessibility prompts appear)
- [x] T004 [P] Create base app shell and menu bar entry in `Voxify/Voxify/App/` (AC: menu bar icon appears)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T005 Implement shared models for dictation state in `Packages/Shared/Sources/Shared/` (AC: status enum covers lifecycle)
- [x] T006 Implement settings storage service in `Voxify/Voxify/Services/SettingsStore.swift` (AC: read/write for prefs)
- [x] T007 Implement personal dictionary storage in `Voxify/Voxify/Services/DictionaryStore.swift` (AC: CRUD persists locally)
- [x] T008 Implement permissions manager in `Voxify/Voxify/Services/PermissionsManager.swift` (AC: mic/accessibility status surfaced)
- [x] T009 [P] Create test harness project targets in `Tests/Unit/` and `Tests/Integration/` (AC: tests run in Xcode)
- [x] T010 [P] Add logging utilities in `Packages/Shared/Sources/Shared/Logging.swift` (AC: log levels compile)
- [x] T011 Implement dictation session model in `Voxify/Voxify/Models/DictationSession.swift` (AC: lifecycle transitions valid)
- [x] T012 Implement active app detector in `Packages/ContextDetector/Sources/ContextDetector/` (AC: returns bundle ID)

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Real-Time Dictation Everywhere (Priority: P1) 🎯 MVP

**Goal**: Start dictation from anywhere and insert polished text in real time

**Independent Test**: Dictate in Mail, Notes, and Slack with live insertion and preview

### Tests for User Story 1 (REQUIRED) ⚠️

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [x] T013 [P] [US1] Unit test dictation session state transitions in `Tests/Unit/DictationSessionTests.swift` (AC: all transitions asserted)
- [x] T014 [P] [US1] Integration test live dictation pipeline in `Tests/Integration/DictationPipelineTests.swift` (AC: mock audio -> polished output)

### Implementation for User Story 1

- [x] T015 [P] [US1] Implement audio capture stream in `Packages/AudioEngine/Sources/AudioEngine/AudioCapture.swift` (AC: emits PCM chunks)
- [x] T016 [P] [US1] Implement whisper.cpp STT adapter in `Packages/STTService/Sources/STTService/WhisperAdapter.swift` (AC: chunk -> partial text)
- [x] T017 [P] [US1] Implement STT service interface in `Packages/STTService/Sources/STTService/STTService.swift` (AC: streams partial/final)
- [x] T018 [P] [US1] Implement polishing engine wrapper in `Packages/PolishingService/Sources/PolishingService/LocalPolisher.swift` (AC: text -> polished)
- [x] T019 [P] [US1] Implement polishing service interface in `Packages/PolishingService/Sources/PolishingService/PolishingService.swift` (AC: sync/async polish)
- [x] T020 [P] [US1] Implement dictation coordinator in `Voxify/Voxify/Features/Dictation/DictationCoordinator.swift` (AC: pipeline orchestration)
- [x] T021 [US1] Implement text insertion service in `Packages/TextInserter/Sources/TextInserter/TextInserter.swift` (AC: inserts into focused field)
- [x] T022 [US1] Build live preview model in `Voxify/Voxify/Features/Dictation/DictationViewModel.swift` (AC: raw/polished updates)
- [x] T023 [US1] Build floating preview UI in `Voxify/Voxify/UI/Dictation/DictationOverlayView.swift` (AC: visible only when active)
- [x] T024 [US1] Implement no-focus popup copy flow in `Voxify/Voxify/UI/Dictation/NoFocusPopupView.swift` (AC: shows captured text)
- [x] T025 [US1] Wire menu bar start/stop to coordinator in `Voxify/Voxify/App/MenuBarController.swift` (AC: start/stop toggles)

**Checkpoint**: User Story 1 should be fully functional and testable independently

---

## Phase 4: User Story 2 - Voice Commands and Speak-to-Edit (Priority: P2)

**Goal**: Issue explicit voice commands to edit and format selected text

**Independent Test**: Select text and apply "command: undo" and "command: new paragraph"

### Tests for User Story 2 (REQUIRED) ⚠️

- [x] T026 [P] [US2] Unit test command parsing in `Tests/Unit/VoiceCommandParserTests.swift` (AC: phrases map to actions)

### Implementation for User Story 2

- [x] T027 [US2] Implement command parser in `Voxify/Voxify/Services/VoiceCommandParser.swift` (AC: explicit phrases only)
- [x] T028 [US2] Implement command executor in `Voxify/Voxify/Services/VoiceCommandExecutor.swift` (AC: transforms selection)
- [x] T029 [US2] Integrate commands into dictation flow in `Voxify/Voxify/Features/Dictation/DictationCoordinator.swift` (AC: commands applied)
- [x] T030 [US2] Add command help UI in `Voxify/Voxify/UI/Settings/CommandHelpView.swift` (AC: list visible)

**Checkpoint**: User Story 2 should be functional and testable independently

---

## Phase 5: User Story 3 - Personal Dictionary and Multilingual Support (Priority: P3)

**Goal**: Manage custom vocabulary and support mixed-language dictation

**Independent Test**: Add a term and verify accurate polishing in mixed-language dictation

### Tests for User Story 3 (REQUIRED) ⚠️

- [x] T031 [P] [US3] Unit test dictionary CRUD in `Tests/Unit/DictionaryStoreTests.swift` (AC: add/edit/remove passes)

### Implementation for User Story 3

- [x] T032 [US3] Build dictionary management UI in `Voxify/Voxify/UI/Settings/DictionaryView.swift` (AC: add/edit/remove)
- [x] T033 [US3] Integrate dictionary into polishing in `Packages/PolishingService/Sources/PolishingService/PolishingService.swift` (AC: terms preserved)
- [x] T034 [US3] Add language auto-detect hook in `Packages/STTService/Sources/STTService/STTService.swift` (AC: language codes emitted)

**Checkpoint**: User Story 3 should be functional and testable independently

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [x] T035 [P] Add settings window UI in `Voxify/Voxify/UI/Settings/SettingsView.swift` (AC: opens from menu)
- [x] T036 Add performance and privacy checks in `Tests/Integration/PerformancePrivacyTests.swift` (AC: latency and retention tests)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
  - User stories can then proceed in parallel (if staffed)
  - Or sequentially in priority order (P1 → P2 → P3)
- **Polish (Final Phase)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P2)**: Can start after Foundational (Phase 2) - Depends on P1 dictation pipeline
- **User Story 3 (P3)**: Can start after Foundational (Phase 2) - Depends on P1 dictation pipeline

### Within Each User Story

- Tests MUST be written and FAIL before implementation
- Models before services
- Services before UI integration
- Story complete before moving to next priority

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel
- All Foundational tasks marked [P] can run in parallel (within Phase 2)
- Once Foundational phase completes, P1 can start; P2/P3 can run after P1 pipeline
- All tests for a user story marked [P] can run in parallel

---

## Parallel Example: User Story 1

```bash
# Launch all tests for User Story 1 together:
Task: "Unit test dictation session state transitions in Tests/Unit/DictationSessionTests.swift"
Task: "Integration test live dictation pipeline in Tests/Integration/DictationPipelineTests.swift"

# Launch core services in parallel:
Task: "Implement audio capture stream in Packages/AudioEngine/Sources/AudioEngine/AudioCapture.swift"
Task: "Implement whisper.cpp STT adapter in Packages/STTService/Sources/STTService/WhisperAdapter.swift"
Task: "Implement polishing engine wrapper in Packages/PolishingService/Sources/PolishingService/LocalPolisher.swift"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Test User Story 1 independently
5. Demo MVP

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 → Test independently → Demo (MVP!)
3. Add User Story 2 → Test independently → Demo
4. Add User Story 3 → Test independently → Demo
5. Each story adds value without breaking previous stories
