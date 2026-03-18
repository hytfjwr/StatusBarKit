# StatusBarKit

A macOS plugin SDK for building dynamic status bar widgets. StatusBarKit provides the foundation for creating extensible status bar applications with a plugin architecture, SwiftUI-based widgets, popup panels with glass effects, and a runtime theme system.

## Requirements

- macOS 26+
- Swift 6.2+
- Xcode 26+

## Installation

### Swift Package Manager

Add StatusBarKit as a dependency in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/hytfjwr/StatusBarKit.git", from: "1.0.0"),
]
```

Then add it to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: ["StatusBarKit"]
)
```

## Quick Start

### 1. Define a Widget

```swift
import StatusBarKit
import SwiftUI

@MainActor
final class HelloWidget: StatusBarWidget {
    let id = "hello"
    let position: WidgetPosition = .center
    let updateInterval: TimeInterval? = nil
    let sfSymbolName = "hand.wave"

    func start() {}
    func stop() {}

    func body() -> some View {
        Text("Hello, StatusBar!")
    }
}
```

### 2. Create a Plugin

```swift
import StatusBarKit

@MainActor
final class HelloPlugin: StatusBarPlugin {
    let manifest = PluginManifest(
        id: "com.example.hello",
        name: "Hello"
    )

    var widgets: [any StatusBarWidget] {
        [HelloWidget()]
    }
}
```

### 3. Export the Plugin Entry Point

Plugins are loaded as dynamic libraries. Expose a C-callable factory function using `@_cdecl` and `PluginBox`:

```swift
@_cdecl("createStatusBarPlugin")
public func createStatusBarPlugin() -> UnsafeMutableRawPointer {
    let box = PluginBox { HelloPlugin() }
    return Unmanaged.passRetained(box).toOpaque()
}
```

### 4. Add a Plugin Manifest

Create a `manifest.json` in your plugin bundle:

```json
{
    "id": "com.example.hello",
    "name": "Hello",
    "version": "1.0.0",
    "statusBarKitVersion": "1.0.0",
    "swiftVersion": "6.2",
    "entrySymbol": "createStatusBarPlugin"
}
```

## Architecture

```
StatusBarKit
├── Plugin System     – dylib loading, manifests, semantic version compatibility
├── Widget System     – StatusBarWidget protocol, type-erased wrappers, layout persistence
├── Configuration     – YAML-based hot-reload config with WidgetConfigProvider
├── UI Components     – PopupPanel, glass effects, reusable popup building blocks
├── Theme System      – Runtime theme injection via ThemeProvider protocol
└── Utilities         – ShellCommand, AppIconProvider, GraphDataBuffer
```

### Plugin Loading Flow

1. Host reads `DylibPluginManifest` (JSON) from the plugin bundle
2. Resolves the C entry symbol via `dlsym` (default: `"createStatusBarPlugin"`)
3. Entry function returns a `PluginBox` wrapping a `@MainActor` factory closure
4. Host calls `box.factory()` on the main actor to instantiate the plugin
5. Plugin registers its widgets via `register(to: WidgetRegistryProtocol)`

### Version Compatibility

StatusBarKit uses semantic versioning for plugin compatibility:
- **Major** version must match exactly
- Plugin's **minor** version must be <= host's minor version
- **Patch** versions are always compatible

## Example Plugins

- [statusbar-plugin-template](https://github.com/hytfjwr/statusbar-plugin-template) - Starter template for new plugins
- [statusbar-plugin-docker](https://github.com/hytfjwr/statusbar-plugin-docker) - Docker container management
- [statusbar-plugin-spotify](https://github.com/hytfjwr/statusbar-plugin-spotify) - Spotify playback control
- [statusbar-plugin-vpn](https://github.com/hytfjwr/statusbar-plugin-vpn) - VPN connection status
- [statusbar-plugin-aerospace](https://github.com/hytfjwr/statusbar-plugin-aerospace) - AeroSpace window manager integration

## License

MIT License. See [LICENSE](LICENSE) for details.
