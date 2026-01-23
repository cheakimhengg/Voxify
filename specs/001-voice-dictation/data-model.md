# Phase 1 Data Model: Voxify Voice Dictation

## Entities

### Dictation Session
- **id**: UUID (unique per session)
- **status**: enum { idle, listening, processing, paused, completed, error }
- **startedAt**: timestamp
- **endedAt**: timestamp (nullable until completed)
- **appBundleId**: string (active app during dictation start)
- **rawText**: string (ephemeral, in-memory only)
- **polishedText**: string (ephemeral, in-memory only)
- **languageCodes**: list<string> (detected languages in session)
- **audioDeviceId**: string (input device identifier)
- **errorCode**: string (nullable)

**Validation rules**:
- `endedAt` must be >= `startedAt` when present.
- `status` transitions must follow allowed lifecycle.

**State transitions**:
- idle -> listening -> processing -> completed
- listening <-> paused
- any -> error

### Polishing Profile
- **id**: UUID
- **appBundleId**: string (unique key)
- **tone**: enum { formal, casual, technical }
- **formattingRules**: list<string> (e.g., bullets, code blocks)
- **isEnabled**: boolean

**Validation rules**:
- One profile per `appBundleId`.
- `tone` must be one of the defined values.

### Personal Dictionary Entry
- **id**: UUID
- **term**: string (unique per language)
- **languageCode**: string (BCP-47)
- **pronunciationHint**: string (optional)
- **createdAt**: timestamp
- **isEnabled**: boolean

**Validation rules**:
- `term` must be non-empty and <= 128 chars.
- `languageCode` must be valid BCP-47.

### Voice Command
- **id**: UUID
- **phrase**: string (e.g., "command: undo")
- **action**: enum { undo, redo, newLine, newParagraph, deleteLastSentence,
  rewriteTone, formatBullets, formatNumbered, insertEmoji }
- **parameters**: map<string,string> (optional)
- **isEnabled**: boolean

**Validation rules**:
- `phrase` must be unique.
- `action` must map to a supported operation.
