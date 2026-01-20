# Feature Specification: Voxify Voice Dictation

**Feature Branch**: `001-voice-dictation`  
**Created**: 2026-01-20  
**Status**: Draft  
**Input**: User description: "Build a completely free, open-source macOS voice dictation app called Voxify that is functionally identical to Typeless in core intelligence and user experience. Voxify turns natural spoken language into beautifully polished, professional text in real time — exactly like Typeless — but 100% free, privacy-first, and open source. Core Functionality (must match Typeless): - Real-time dictation: Speak naturally and see polished text appear instantly in any text field. - Intelligent polishing: Automatically remove all filler words (um, uh, like, you know, so), eliminate repetitions and stutters, correct grammar & punctuation, handle mid-sentence corrections/edits seamlessly. - Smart auto-formatting: Detect and format spoken content into proper paragraphs, bullet points, numbered lists, code blocks, tables when spoken naturally. - Context-aware tone adaptation: Automatically adjust tone and style based on the active application (formal/professional in Mail/TextEdit/Docs, casual/conversational in Messages/Slack, technical/precise in Xcode or code editors). - Speak-to-edit / voice commands: Select text and dictate changes (make this more professional, shorten this paragraph, turn into bullets, add more details). Natural commands like new line, new paragraph, undo that, delete last sentence, insert smiley. - Personal dictionary: Users can add custom words, names, acronyms, technical terms — saved locally and respected during polishing. - Works everywhere: System-wide dictation — start with global hotkey or menu bar button, insert polished text into any focused text field. - Multilingual support: Auto-detect language and handle 100+ languages, including code-switching in the same sentence. - Live preview: Show raw + polished text side-by-side during dictation for easy editing. - High accuracy & speed: 4x+ faster than typing, excellent with accents and background noise. Why: To give everyone a powerful, intelligent voice dictation tool without paying subscriptions or sacrificing privacy — exactly the experience Typeless provides, but free and open for the world. MVP Scope: macOS-only native app. No iOS/Android/web yet."

## Clarifications

### Session 2026-01-20

- Q: Dictation activation methods → A: Both global hotkey and menu bar control
- Q: Dictation behavior with no focused field → A: Show popup with captured text for copy
- Q: Dictation preview storage policy → A: Ephemeral only, cleared when dictation stops
- Q: Voice command trigger style → A: Explicit command phrases (e.g., "command: undo")
- Q: Live preview visibility → A: Visible only during active dictation

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Real-Time Dictation Everywhere (Priority: P1)

As a macOS user, I start dictation from a global trigger and see polished text
appear in the currently focused field while I speak.

**Why this priority**: This is the core experience that makes Voxify valuable.

**Independent Test**: Start dictation in three different apps and verify live
polished text insertion without leaving the app.

**Acceptance Scenarios**:

1. **Given** a focused editable field in Mail, **When** I start dictation and
   speak a short paragraph, **Then** the field receives polished text with
   filler words removed and correct punctuation in real time.
2. **Given** dictation is active, **When** I pause and then resume speaking,
   **Then** the live preview continues and the inserted text remains coherent
   without duplicated phrases.

---

### User Story 2 - Voice Commands and Speak-to-Edit (Priority: P2)

As a user, I can issue natural editing commands to adjust existing text without
switching to the keyboard.

**Why this priority**: Editing and formatting by voice is required to match
Typeless-level productivity.

**Independent Test**: Select text and issue voice commands to rewrite and
reformat it without manual typing.

**Acceptance Scenarios**:

1. **Given** a selected paragraph, **When** I say "make this more professional",
   **Then** the selected text is replaced with a more formal rewrite.
2. **Given** dictation is active, **When** I say "new paragraph" or "undo that",
   **Then** the system applies the command immediately and reflects it in the
   preview.

---

### User Story 3 - Personal Dictionary and Multilingual Support (Priority: P3)

As a multilingual user, I can dictate in multiple languages and add custom
terms that are respected during polishing.

**Why this priority**: Personal vocabulary and language coverage are critical to
accuracy and inclusivity.

**Independent Test**: Add custom terms and dictate a mixed-language sentence
while verifying correct recognition and polishing.

**Acceptance Scenarios**:

1. **Given** I add a custom term to my dictionary, **When** I dictate a sentence
   using it, **Then** the term appears correctly in polished output.
2. **Given** a sentence with mixed languages, **When** I dictate it, **Then** the
   system auto-detects languages and preserves meaning across the switch.

---

### Edge Cases

- What happens when microphone permission is denied or revoked mid-session?
- How does the system handle dictation when no editable field is focused?
- What happens if the active app changes during dictation?
- How does the system behave in high-noise or low-volume environments?
- How are ambiguous voice commands handled (e.g., "undo" vs. "undo that")?

### Assumptions

- Dictation runs offline by default, with any external processing only by
  explicit user choice.
- The product is macOS-only for this MVP scope.
- Users expect system-wide triggering via a global shortcut or menu bar control.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST support real-time dictation into any focused text
  field across macOS apps.
- **FR-002**: System MUST present a live preview of raw speech and polished text
  side-by-side during dictation and hide it when dictation is inactive.
- **FR-003**: System MUST remove filler words, repetitions, and stutters from
  polished output without user intervention.
- **FR-004**: System MUST correct grammar and punctuation in polished output.
- **FR-005**: System MUST apply smart auto-formatting for paragraphs, bullet
  lists, numbered lists, code blocks, and tables when spoken naturally.
- **FR-006**: System MUST adapt tone based on the active application context
  (formal, casual, or technical).
- **FR-007**: System MUST provide voice commands for editing, formatting, and
  navigation using explicit command phrases (e.g., "command: new line",
  "command: undo").
- **FR-008**: Users MUST be able to add, edit, and remove personal dictionary
  entries that influence polishing.
- **FR-009**: System MUST auto-detect language and support at least 100
  languages, including mixed-language dictation.
- **FR-010**: System MUST insert polished text without saving or transmitting
  voice data unless the user explicitly opts in.
- **FR-011**: System MUST allow users to start and stop dictation from anywhere
  in the system via both a global hotkey and a menu bar control.
- **FR-013**: When no editable field is focused, the system MUST present a
  popup containing the captured text for copy.
- **FR-012**: System MUST provide clear feedback when dictation is active,
  paused, or unavailable.

### Non-Functional Requirements *(mandatory)*

- **NFR-001**: Privacy: All processing MUST be local by default, with explicit
  user consent for any external processing.
- **NFR-007**: Privacy: Live preview text MUST be ephemeral and cleared when a
  dictation session ends.
- **NFR-002**: Performance: 95% of short phrases MUST appear in the target field
  within 800 ms of speech completion.
- **NFR-003**: Responsiveness: The live preview MUST update within 200 ms of
  speech during active dictation.
- **NFR-004**: UX Consistency: Behavior and formatting MUST be consistent across
  common apps (Mail, Notes, Slack, and Xcode).
- **NFR-005**: Accessibility: Dictation status and controls MUST be usable with
  VoiceOver and keyboard-only navigation.
- **NFR-006**: Testing: Core polishing logic and dictation flow MUST be covered
  by unit and integration tests for critical paths.

### Key Entities *(include if feature involves data)*

- **Dictation Session**: A time-bounded voice input session with raw and
  polished text outputs.
- **Polishing Profile**: Context rules that adjust tone and formatting per app.
- **Personal Dictionary Entry**: User-defined term with spelling and optional
  pronunciation hints.
- **Voice Command**: A recognized instruction that triggers editing or
  navigation changes.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 95% of short-phrase dictations appear in the target field within
  800 ms of speech completion.
- **SC-002**: At least 90% of users can complete a dictation session with no
  manual correction for filler removal and punctuation.
- **SC-003**: At least 90% of users can successfully complete a voice-driven
  edit (rewrite or reformat) on the first attempt.
- **SC-004**: Language auto-detection achieves 95% accuracy on a multilingual
  test set with code-switching examples.
- **SC-005**: 99% of dictation sessions complete without app crashes or freezes.
- **SC-006**: User satisfaction averages 4.5/5 or higher for dictation quality
  in post-session surveys.
