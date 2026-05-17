# AGENTS.md

Guidance for Codex and other coding agents working in this repo.

## Default Workflow

- Read the relevant Swift files before editing.
- Keep changes tightly scoped to the user's request.
- Do not rewrite unrelated views or refactor broad areas unless explicitly asked.
- Preserve the preview compile/load flow unless the request is specifically about that flow.
- After Swift code changes, run:
- Report whether the build succeeded.

## Swift Style

- Absolutely NO Singletons
  - Singletons need a proposal before implementing
- Match the existing file style.
- Use `///` comments above important functions, especially helpers that are not obvious.
- Include small examples in comments when they clarify behavior.
- Avoid noisy comments that simply restate a line of code.
- Keep code ASCII unless the surrounding file already uses non-ASCII for a clear reason.

When breaking up a type into extensions:

1. The main body contains ONLY:
   - Stored properties
   - init (if custom)
   - The single public entry point that triggers the type's main job

2. Each extension must be named after a CONCEPT (what it does), 
   not a category (what it is). Prefer verb phrases.
   
3. The order of extensions should follow the narrative of how 
   the type is actually used — setup → trigger → work → output.
   In ViewModel: Workspace Setup → Build/Preview → Code Generation

- Break up long classes/structs/actors into extensions that tell a story for other people reading

## Public-Safe Paths

Never hardcode a developer-specific path such as:

```swift
"/Users/aryanrogye/..."
```

This project is public, so paths should work for other users.

## SwiftUI Editing Assistant Rules

When changing the generated/editor SwiftUI source through Codex:

- Make the smallest in-place edit that satisfies the request.
- Preserve layout, state, styling, and root view names unless explicitly asked to change them.
- Do not add `@main`, `App`, `Scene`, or `WindowGroup`.
- Do not add placeholder comments like `// existing code here`.
- Do not invent unrelated features.
- Return complete Swift source when replacing the editor text.

## SwiftUI/AppKit Interop

- When a SwiftUI view needs AppKit behavior, start with the smallest AppKit hook that solves the exact problem.
  - Examples: `acceptsFirstMouse(for:)`, `mouseDown(with:)`, `NSTrackingArea`, `NSTextFieldDelegate`, or first-responder handling.
- Avoid broad `hitTest(_:)` overrides unless there is no smaller option. They can trap events, steal clicks from hosted SwiftUI subviews, or make only part of a collection view behave correctly.
- Before adding a coordinator-level routing system, custom click mapping, or extra state layer, test the simple AppKit primitive first.
  - Example: for clickable `NSCollectionViewItem` rows hosting SwiftUI content, prefer an `NSView` item shell with `acceptsFirstMouse(for:)` and `mouseDown(with:)` before overriding collection-view hit testing.
- Keep SwiftUI as the owner of app state and AppKit as the owner of imperative edge behavior. Do not duplicate source of truth between both sides.
- If a bug is about focus, clicks, hover, or responder-chain behavior, describe the actual event path in comments or review notes before expanding the architecture.

## Git Safety

- The worktree may contain user changes.
- Do not revert user changes unless explicitly asked.
- If unrelated files are dirty, leave them alone.
- If touching a file with existing changes, read it first and preserve the user's work.
