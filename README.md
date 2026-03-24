# StatusBarKit

A macOS plugin SDK for building dynamic status bar widgets. StatusBarKit provides the foundation for creating extensible status bar applications with a plugin architecture, SwiftUI-based widgets, popup panels with glass effects, and a runtime theme system.

## Products

This package provides two library targets:

| Library | Platform | Description |
|---|---|---|
| **StatusBarKit** | macOS 26+ | Full SDK — widgets, popups, themes, plugin system (dynamic library) |
| **StatusBarIPC** | macOS 15+ | IPC protocol types for CLI communication (static library) |

`StatusBarKit` re-exports `StatusBarIPC`, so existing code that `import StatusBarKit` gains access to IPC types automatically. CLI tools that only need wire types can depend on `StatusBarIPC` alone, without the macOS 26 requirement.

## Requirements

- macOS 15+ (StatusBarIPC) / macOS 26+ (StatusBarKit)
- Swift 6.2+
- Xcode 26+

## Installation

### Swift Package Manager

Add StatusBarKit as a dependency in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/hytfjwr/StatusBarKit.git", from: "1.4.0"),
]
```

Then add it to your target:

```swift
// For the full SDK (widgets, popups, plugins):
.target(name: "YourApp", dependencies: ["StatusBarKit"])

// For CLI tools that only need IPC types:
.target(name: "YourCLI", dependencies: [
    .product(name: "StatusBarIPC", package: "StatusBarKit"),
])
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

### 4. Build the Plugin

The easiest way to get started is to clone the [plugin template](https://github.com/hytfjwr/statusbar-plugin-template) and build with `make`:

```bash
make build
```

This builds the dylib and auto-generates the required `manifest.json` for host discovery. See the template repository for the full project structure and build configuration.

## Architecture

```
StatusBarKit
├── StatusBarIPC      – IPC protocol types, message framing, socket path constants
├── Plugin System     – dylib loading, manifests, semantic version compatibility
├── Widget System     – StatusBarWidget protocol, type-erased wrappers, layout persistence
├── Configuration     – YAML-based hot-reload config with WidgetConfigProvider
├── UI Components     – PopupPanel, glass effects, reusable popup building blocks
├── Theme System      – Runtime theme injection via ThemeProvider protocol
└── Utilities         – ShellCommand, AppIconProvider, GraphDataBuffer
```

### IPC Protocol (StatusBarIPC)

StatusBarIPC defines the wire protocol for communication between the StatusBar app and the `sbar` CLI (bundled in [StatusBar](https://github.com/hytfjwr/StatusBar)):

- **`IPCRequest` / `IPCResponse`** — versioned request/response envelopes
- **`IPCCommand`** — supported commands: `list`, `getWidget`, `setWidget`, `setGlobal`, `reload`
- **`IPCFraming`** — 4-byte length-prefixed message framing over Unix domain sockets
- **`WidgetInfoDTO`** — serializable widget info for transfer between processes

Shared Foundation-only types (`ConfigValue`, `WidgetPosition`, `WidgetLayoutEntry`) live in StatusBarIPC so they can be used by both the full SDK and lightweight CLI tools.

### Plugin Loading Flow

1. Host discovers plugin bundles and reads the auto-generated `manifest.json` (`DylibPluginManifest`)
2. Verifies version compatibility (semver) and resolves the C entry symbol via `dlsym`
3. Entry function returns a `PluginBox` wrapping a `@MainActor` factory closure
4. Host calls `box.factory()` on the main actor to instantiate the `StatusBarPlugin`
5. Plugin's `register(to:)` is called — each widget is registered to the host's `WidgetRegistryProtocol`

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
- [statusbar-plugin-claude](https://github.com/hytfjwr/statusbar-plugin-claude) - Claude Code status

## License

MIT License. See [LICENSE](LICENSE) for details.
