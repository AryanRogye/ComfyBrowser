# ComfyBrowser

> A browser I'm building because every other browser treats RAM like it's free.

---

## Why

Chrome eats memory. Arc is beautiful but bloated. Orion is promising but rough. None of them let me *switch how I browse* based on my mood or task. I have ADHD and I context-switch constantly — I want a browser that adapts to me, not one I have to fight.

ComfyBrowser is my answer: **one browser, three UIs, one memory budget.**

---

## The Core Idea

Three swappable UI modes that I can toggle at any time:

### 🟦 Chrome Mode
Familiar. Tabs on top. Fast to reach. No friction.  
For when I just need to get something done without thinking about the browser.

### 🌊 Arc Mode
Sidebar navigation. Spaces. Command bar-first.  
For deep work sessions where I'm staying inside one context for a while.

### 🦁 Orion Mode
Compact. Keyboard-driven. Minimal chrome (heh).  
For research, reading, and when I want the web to feel calm.

---

## The Real Goal: RAM

Every UI mode shares the **same underlying engine and process model**. The UI switching is cosmetic — what matters is that tabs are aggressively managed:

- User should Know about their RAM and what each tab gives

---

## Tech Stack (Planned)

- **Swift + WebKit** — native macOS, WKWebView for rendering
- **SwiftUI** — UI layer for all three modes (same state, different layouts)
- **Comfy ecosystem** — built on the same patterns as ComfyTile, ComfyDisplay, etc.

---

## Status

`[ ] Project scaffolded`  
`[ ] WKWebView wrapper + tab model`  
`[ ] Chrome Mode UI`  
`[ ] Arc Mode UI`  
`[ ] Orion Mode UI`  
`[ ] UI mode switcher`  
`[ ] Tab suspension engine`  
`[ ] Memory pressure monitoring`  
`[ ] Per-tab memory caps`  

---

## Notes to Self

- Keep the process model dead simple first. Don't over-engineer tab suspension before the UI even works.
- All three UIs should share the same `BrowserViewModel` — the layout changes, not the data.
- Look at how Safari's `WKProcessPool` configuration affects memory — there's probably something there.
- The mode switcher should be a single keyboard shortcut. Something fast.
- Don't ship this. This is for me.
