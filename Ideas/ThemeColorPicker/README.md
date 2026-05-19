# ThemeColorPicker

A reusable SwiftUI browser-theme color picker component.

The package exposes a neutral `ThemeColorPicker` library target and a small
`ColorPickerDemo` executable. The component is original SwiftUI code and does
not include third-party browser source files, CSS, markup, or image assets.

## Usage

Add this folder as a local Swift package dependency, then import the library:

```swift
import ThemeColorPicker
```

Use a `ThemeColorPickerValue` binding wherever the picker should edit theme
state:

```swift
@State private var theme = ThemeColorPickerValue()

var body: some View {
    ThemeColorPicker(value: $theme)
}
```

For a background preview, render:

```swift
ThemeColorBackground(value: theme)
```

## Demo

Run the demo with:

```sh
swift run ColorPickerDemo
```
