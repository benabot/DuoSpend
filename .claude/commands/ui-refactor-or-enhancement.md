---
name: ui-refactor-or-enhancement
description: Workflow command scaffold for ui-refactor-or-enhancement in DuoSpend.
allowed_tools: ["Bash", "Read", "Write", "Grep", "Glob"]
---

# /ui-refactor-or-enhancement

Use this workflow when working on **ui-refactor-or-enhancement** in `DuoSpend`.

## Goal

Refactors or enhances the user interface, often touching multiple view and component files, sometimes with associated model or asset updates.

## Common Files

- `DuoSpend/Views/*.swift`
- `DuoSpend/Views/Components/*.swift`
- `DuoSpend/Resources/Assets.xcassets/**/*`
- `DuoSpend.xcodeproj/project.pbxproj`
- `DuoSpend/App/DuoSpendApp.swift`
- `DuoSpend/DuoSpend.entitlements`

## Suggested Sequence

1. Understand the current state and failure mode before editing.
2. Make the smallest coherent change that satisfies the workflow goal.
3. Run the most relevant verification for touched files.
4. Summarize what changed and what still needs review.

## Typical Commit Signals

- Modify multiple SwiftUI view/component files to update UI elements.
- Update or add assets (e.g., icons, colors) in xcassets.
- Update DuoSpend.xcodeproj/project.pbxproj if new files/assets are added.
- Update entitlements or configuration if needed for new UI features.
- Test and tweak navigation or view logic as needed.

## Notes

- Treat this as a scaffold, not a hard-coded script.
- Update the command if the workflow evolves materially.