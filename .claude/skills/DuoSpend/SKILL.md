---
name: duospend-conventions
description: Development conventions and patterns for DuoSpend. Swift project with mixed commits.
---

# Duospend Conventions

> Generated from [benabot/DuoSpend](https://github.com/benabot/DuoSpend) on 2026-03-23

## Overview

This skill teaches Claude the development patterns and conventions used in DuoSpend.

## Tech Stack

- **Primary Language**: Swift
- **Architecture**: hybrid module organization
- **Test Location**: separate

## When to Use This Skill

Activate this skill when:
- Making changes to this repository
- Adding new features following established patterns
- Writing tests that match project conventions
- Creating commits with proper message format

## Commit Conventions

Follow these commit message conventions based on 25 analyzed commits.

### Commit Style: Mixed Style

### Prefixes Used

- `feat`
- `fix`
- `docs`
- `simplify`
- `revert`

### Message Guidelines

- Average message length: ~62 characters
- Keep first line concise and descriptive
- Use imperative mood ("Add feature" not "Added feature")


*Commit message example*

```text
feat: ajout sync MultipeerConnectivity entre 2 iPhones
```

*Commit message example*

```text
fix: PDF share — présenter UIActivityViewController directement au lieu du wrapper SwiftUI
```

*Commit message example*

```text
docs: amélioration complète du README
```

*Commit message example*

```text
Simplify: stable navigation + clean DuoSpendApp splash + passing tests
```

*Commit message example*

```text
Revert: restore original ProjectListView navigation (was working)
```

*Commit message example*

```text
end phase 1
```

*Commit message example*

```text
feat: add PDF export with UIGraphicsPDFRenderer (full project summary)
```

*Commit message example*

```text
fix: widget vide — WidgetCenter.reloadAllTimelines() après chaque save
```

## Architecture

### Project Structure: Single Package

This project uses **hybrid** module organization.

### Guidelines

- This project uses a hybrid organization
- Follow existing patterns when adding new code

## Code Style

### Language: Swift

### Naming Conventions

| Element | Convention |
|---------|------------|
| Files | PascalCase |
| Functions | camelCase |
| Classes | PascalCase |
| Constants | SCREAMING_SNAKE_CASE |

### Import Style: Relative Imports

### Export Style: Named Exports


*Preferred import style*

```typescript
// Use relative imports
import { Button } from '../components/Button'
import { useAuth } from './hooks/useAuth'
```

*Preferred export style*

```typescript
// Use named exports
export function calculateTotal() { ... }
export const TAX_RATE = 0.1
export interface Order { ... }
```

## Common Workflows

These workflows were detected from analyzing commit patterns.

### Feature Development

Standard feature implementation workflow

**Frequency**: ~13 times per month

**Steps**:
1. Add feature implementation
2. Add tests for feature
3. Update documentation

**Files typically involved**:
- `duospend/views/components/*`
- `**/*.test.*`

**Example commit sequence**:
```
feat: DuoLogoView + UI orientée couple
Merge pull request #2 from benabot/dev
feat: icône app, UI CreateProjectView colorée, DuoLogoView aligné, team ID signing
```

### Feature Module Addition

Adds a new feature or module, typically involving new service/model/view/viewmodel files, updates to the Xcode project, and sometimes documentation or tests.

**Frequency**: ~2 times per month

**Steps**:
1. Create new Swift files for models/services/viewmodels/views in appropriate folders.
2. Update DuoSpend.xcodeproj/project.pbxproj to include new files.
3. Update Info.plist or entitlements if needed (e.g., permissions, app groups).
4. Integrate new feature into existing views (e.g., ProjectDetailView.swift).
5. Add or update documentation (e.g., docs/DECISIONS.md, docs/TODO.md).
6. Write unit tests if applicable.

**Files typically involved**:
- `DuoSpend.xcodeproj/project.pbxproj`
- `DuoSpend/Models/*.swift`
- `DuoSpend/Services/*.swift`
- `DuoSpend/ViewModels/*.swift`
- `DuoSpend/Views/*.swift`
- `DuoSpend/Views/Components/*.swift`
- `DuoSpend/Info.plist`
- `DuoSpend/DuoSpend.entitlements`
- `DuoSpendWidget/*`
- `docs/DECISIONS.md`
- `docs/TODO.md`
- `DuoSpendTests/*.swift`

**Example commit sequence**:
```
Create new Swift files for models/services/viewmodels/views in appropriate folders.
Update DuoSpend.xcodeproj/project.pbxproj to include new files.
Update Info.plist or entitlements if needed (e.g., permissions, app groups).
Integrate new feature into existing views (e.g., ProjectDetailView.swift).
Add or update documentation (e.g., docs/DECISIONS.md, docs/TODO.md).
Write unit tests if applicable.
```

### Ui Refactor Or Enhancement

Refactors or enhances the user interface, often touching multiple view and component files, sometimes with associated model or asset updates.

**Frequency**: ~2 times per month

**Steps**:
1. Modify multiple SwiftUI view/component files to update UI elements.
2. Update or add assets (e.g., icons, colors) in xcassets.
3. Update DuoSpend.xcodeproj/project.pbxproj if new files/assets are added.
4. Update entitlements or configuration if needed for new UI features.
5. Test and tweak navigation or view logic as needed.

**Files typically involved**:
- `DuoSpend/Views/*.swift`
- `DuoSpend/Views/Components/*.swift`
- `DuoSpend/Resources/Assets.xcassets/**/*`
- `DuoSpend.xcodeproj/project.pbxproj`
- `DuoSpend/App/DuoSpendApp.swift`
- `DuoSpend/DuoSpend.entitlements`

**Example commit sequence**:
```
Modify multiple SwiftUI view/component files to update UI elements.
Update or add assets (e.g., icons, colors) in xcassets.
Update DuoSpend.xcodeproj/project.pbxproj if new files/assets are added.
Update entitlements or configuration if needed for new UI features.
Test and tweak navigation or view logic as needed.
```

### Bugfix Or Small Feature Tweak

Fixes a bug or makes a small tweak, usually affecting a small number of files (often just one or two).

**Frequency**: ~4 times per month

**Steps**:
1. Identify the affected SwiftUI view/service file(s).
2. Make the fix or tweak in the relevant file(s).
3. Test the change in the app.
4. Commit with a descriptive message.

**Files typically involved**:
- `DuoSpend/Views/*.swift`
- `DuoSpend/Views/Components/*.swift`
- `DuoSpend/Services/*.swift`

**Example commit sequence**:
```
Identify the affected SwiftUI view/service file(s).
Make the fix or tweak in the relevant file(s).
Test the change in the app.
Commit with a descriptive message.
```

### Documentation Update

Updates or adds documentation files, such as README, DECISIONS.md, TODO.md, or project phase documentation.

**Frequency**: ~2 times per month

**Steps**:
1. Edit or create documentation files in the docs/ folder or root (e.g., README.md, DECISIONS.md, TODO.md, CLAUDE.md).
2. Commit with a message summarizing the documentation changes.

**Files typically involved**:
- `README.md`
- `docs/*.md`
- `CLAUDE.md`

**Example commit sequence**:
```
Edit or create documentation files in the docs/ folder or root (e.g., README.md, DECISIONS.md, TODO.md, CLAUDE.md).
Commit with a message summarizing the documentation changes.
```

### Revert Feature Or Fix

Reverts a previous commit, typically a feature or fix, to restore prior behavior.

**Frequency**: ~1 times per month

**Steps**:
1. Identify the commit to revert.
2. Use git revert or manual rollback to restore previous file versions.
3. Commit the revert with a message referencing the original commit.

**Files typically involved**:
- `DuoSpend/Views/*.swift`
- `DuoSpend/Views/Components/*.swift`
- `DuoSpend.xcodeproj/project.pbxproj`

**Example commit sequence**:
```
Identify the commit to revert.
Use git revert or manual rollback to restore previous file versions.
Commit the revert with a message referencing the original commit.
```


## Best Practices

Based on analysis of the codebase, follow these practices:

### Do

- Use PascalCase for file names
- Prefer named exports

### Don't

- Don't deviate from established patterns without discussion

---

*This skill was auto-generated by [ECC Tools](https://ecc.tools). Review and customize as needed for your team.*
