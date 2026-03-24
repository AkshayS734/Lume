# Lume 🕰️

A premium, minimalistic native macOS desktop clock application that renders directly on the wallpaper layer. Built using SwiftUI and AppKit, Lume provides an unobtrusive, beautiful time display that integrates seamlessly into your macOS environment.

## 🌟 Features

- **Wallpaper Layer Rendering:** Sits elegantly beneath desktop icons but above the wallpaper (`kCGDesktopWindowLevel + 1`).
- **Multi-Display Support:** Automatically creates native, borderless, click-through windows for every connected display.
- **Menu Bar Controls:** Lives in the menu bar as an agent app (no Dock clutter), providing quick toggles for visibility, repositioning, and formatting.
- **Fluid Animations:** Utilizes beautiful SwiftUI `.numericText()` content transitions for smooth, modern digit ticking.
- **Customizable:** Adjustable font sizes, opacities, 12/24-hour formats, and date visibility via a native macOS Settings pane.
- **Interactive Repositioning:** A global hotkey (⌘R or via menu bar) temporarily enables mouse events to drag the clock anywhere on the screen.

## 🏗️ Architecture

- **App Entry:** Bridges between the SwiftUI lifecycle and `AppDelegate` to manage `.borderless` `NSWindow` instances per screen.
- **UI:** Written entirely in SwiftUI. A `ClockView` displays the time, while an inline `DragOverlayView` captures gestures during repositioning mode.
- **View Model:** `ClockViewModel` relies on a `Timer` attached to the main runloop, intelligently synchronizing ticks to the exact second boundary for perfect rhythm.
- **State Management:** `PreferencesManager` acts as a central `@MainActor` ObservableObject, storing user preferences natively via `@AppStorage` (`UserDefaults`).

## 🚀 Installation & Running

1. Open `Lume.xcodeproj` (or Swift Package if configured as such) in Xcode.
2. Ensure your target is set to **My Mac**.
3. Build and Run (`Cmd + R`).
4. The app will launch silently. Look for the **Clock icon** in your macOS menu bar.
5. Click the menu bar icon to access Settings, toggle the display, or reposition the clock.

---

## 💻 Requirements

- macOS 12.0 or later.
- Xcode 14.0 or later (for building from source).

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

To contribute:

1. Fork the project.
2. Create your feature branch (`git checkout -b feature/AmazingFeature`).
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`).
4. Push to the branch (`git push origin feature/AmazingFeature`).
5. Open a Pull Request.

Please ensure your code adheres to standard Swift formatting guidelines and tested against multiple monitor configurations if making layout changes.

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

## 🙏 Acknowledgements

- Built entirely with [SwiftUI](https://developer.apple.com/xcode/swiftui/)
- Inspired by minimal desktop aesthetics and the need for a native, lightweight clock utility.
