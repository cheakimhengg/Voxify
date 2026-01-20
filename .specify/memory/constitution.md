<!--
Sync Impact Report
- Version change: unversioned template -> 1.0.0
- Modified principles: placeholders -> nine Voxify principles
- Added sections: Product & Engineering Standards, Development Workflow & Quality Gates
- Removed sections: none
- Templates requiring updates:
  - ✅ .specify/templates/plan-template.md
  - ✅ .specify/templates/spec-template.md
  - ✅ .specify/templates/tasks-template.md
  - ⚠ .specify/templates/commands/ (directory missing)
- Follow-up TODOs:
  - TODO(RATIFICATION_DATE): original adoption date not found in repo
-->
# Voxify Constitution

## Core Principles

### I. Radical Privacy & Freedom
Voxify MUST be 100% free forever with no subscriptions, ads, tracking, or word
limits. Data retention is prohibited: all processing MUST be local or use
user-supplied API keys with explicit consent. Voice data MUST NOT be saved or
sent to servers without user authorization. Rationale: privacy and autonomy are
the product.

### II. Open Source & Community-First
Voxify MUST ship under the MIT license with a public GitHub repository from day
one. Code MUST be modular, readable, and documented to invite contributions and
forks. Community inputs MUST be respected through clear contribution guidelines
and transparent decision-making. Rationale: trust and longevity depend on
community ownership.

### III. macOS-Native Excellence
Voxify MUST be a polished macOS app built with Swift and SwiftUI, adhering to
macOS Human Interface Guidelines. It MUST support dark/light mode, VoiceOver,
keyboard navigation, and smooth animations. Rationale: native feel and
accessibility are non-negotiable on macOS.

### IV. Code Quality & Maintainability
The architecture MUST follow MVVM with strict typing, meaningful naming, and
clear separation of concerns. Modules MUST remain focused and testable, with
comments only where intent is non-obvious. Rationale: quality and longevity
depend on readable, evolvable code.

### V. Testing Standards
Core logic (polishing, formatting, context detection) MUST have unit tests, and
dictation flow plus text insertion MUST have integration tests. Critical paths
MUST maintain at least 80% coverage, and regressions MUST be blocked by CI.
Rationale: reliability is the user experience.

### VI. Performance Requirements
Short-phrase dictation MUST complete end-to-end in under 800ms, with sustained
60fps UI. CPU and memory usage MUST remain low on M1/M2 Macs. Performance
budgets MUST be measured and enforced for every release. Rationale: dictation
fails if it feels slow.

### VII. User Experience Consistency
The interface MUST remain minimal and intuitive, with consistent behavior
across target apps (Mail, Notes, Slack, Xcode, and others). Errors MUST be
gracefully handled, and microphone access MUST provide instant, explicit
feedback. Rationale: trust depends on predictable behavior.

### VIII. Intelligence & Accuracy
Polishing quality MUST match or exceed Typeless-level results, including filler
removal, repetition cleanup, grammar correction, context-aware tone adaptation,
and smart auto-formatting. Accuracy MUST be measured against curated test sets.
Rationale: intelligence is the core differentiator.

### IX. Inclusivity & Language Support
Voxify MUST support accents, non-native speakers, and at least 100 languages
with auto-detection. Language coverage and accuracy MUST be validated with
diverse sample sets. Rationale: global inclusivity is essential.

## Product & Engineering Standards

- The product MUST remain offline-first by default, with external APIs only
  enabled by explicit user choice.
- The app MUST be macOS-only and Swift/SwiftUI-native until a deliberate, public
  constitution amendment states otherwise.
- Accessibility, privacy, and performance requirements are release blockers and
  MUST be validated before shipping.

## Development Workflow & Quality Gates

- Every change MUST include tests or explicit justification for omission, and
  MUST pass CI before merge.
- PRs MUST include privacy, performance, and UX impact notes.
- Releases MUST include a brief compliance checklist covering the nine
  principles, with evidence links where applicable.

## Governance

- This constitution supersedes all other guidance for Voxify.
- Amendments require a documented proposal, rationale, and explicit approval
  from project maintainers.
- Versioning follows semantic versioning: MAJOR for incompatible governance
  changes, MINOR for new or expanded principles, PATCH for clarifications.
- Compliance MUST be reviewed during PRs and before releases; violations block
  merge or release until resolved.

**Version**: 1.0.0 | **Ratified**: TODO(RATIFICATION_DATE): original adoption date not found in repo | **Last Amended**: 2026-01-20
