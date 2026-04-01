---
name: feature-module-addition
description: Workflow command scaffold for feature-module-addition in DuoSpend.
allowed_tools: ["Bash", "Read", "Write", "Grep", "Glob"]
---

# /feature-module-addition

Use this workflow when working on **feature-module-addition** in `DuoSpend`.

## Goal

Adds a new feature or module, typically involving new service/model/view/viewmodel files, updates to the Xcode project, and sometimes documentation or tests.

## Common Files

- `DuoSpend.xcodeproj/project.pbxproj`
- `DuoSpend/Models/*.swift`
- `DuoSpend/Services/*.swift`
- `DuoSpend/ViewModels/*.swift`
- `DuoSpend/Views/*.swift`
- `DuoSpend/Views/Components/*.swift`

## Suggested Sequence

1. Understand the current state and failure mode before editing.
2. Make the smallest coherent change that satisfies the workflow goal.
3. Run the most relevant verification for touched files.
4. Summarize what changed and what still needs review.

## Typical Commit Signals

- Create new Swift files for models/services/viewmodels/views in appropriate folders.
- Update DuoSpend.xcodeproj/project.pbxproj to include new files.
- Update Info.plist or entitlements if needed (e.g., permissions, app groups).
- Integrate new feature into existing views (e.g., ProjectDetailView.swift).
- Add or update documentation (e.g., docs/DECISIONS.md, docs/TODO.md).

## Notes

- Treat this as a scaffold, not a hard-coded script.
- Update the command if the workflow evolves materially.