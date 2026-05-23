import Foundation

/// Current IPC protocol version. Incremented when breaking changes are made.
public let ipcProtocolVersion: Int = 1

/// Default socket path for IPC communication.
/// Expand `~` at runtime via `FileManager.default.homeDirectoryForCurrentUser`.
public let ipcSocketName = "statusbar.sock"

/// Returns the full path to the IPC socket.
public func ipcSocketPath() -> String {
    FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".config/statusbar/\(ipcSocketName)").path
}

// MARK: - IPCRequest

/// Envelope sent from CLI to the app over the Unix socket.
public struct IPCRequest: Codable, Sendable, Equatable {
    public let version: Int
    public let requestID: String
    public let command: IPCCommand

    public init(version: Int = ipcProtocolVersion, requestID: String = UUID().uuidString, command: IPCCommand) {
        self.version = version
        self.requestID = requestID
        self.command = command
    }
}

// MARK: - IPCCommand

/// All supported IPC commands.
/// Not `@frozen` — new cases can be added in minor versions.
public enum IPCCommand: Codable, Sendable, Equatable {
    /// List all widgets with their layout and settings.
    case list
    /// Get details for a single widget.
    case getWidget(id: String)
    /// Set a single key on a widget's settings.
    case setWidget(id: String, key: String, value: ConfigValue)
    /// Set a global preference by dot-separated key path (e.g. "bar.height").
    case setGlobal(keyPath: String, value: ConfigValue)
    /// Reload configuration from disk.
    case reload
    /// Subscribe to named events. The connection stays open and receives NDJSON lines.
    case subscribe(events: [String])
    /// Send a custom event to plugin widgets that subscribe to the given event name.
    case trigger(event: String, payload: JSONValue?)
    /// Show a toast notification.
    case showToast(request: ToastRequest)
    /// Sync plugins.yml against plugins-lock.yml and the installed plugin registry.
    /// When `frozen` is true, the app resolves from plugins-lock.yml only and does not call GitHub.
    case pluginsSync(frozen: Bool)
    /// List plugin manifest entries with their resolved lock state.
    case pluginsList
    /// Install a plugin declared by source ("github:owner/repo"). When `version` is nil,
    /// installs the latest GitHub release. Writes plugins.yml + plugins-lock.yml and
    /// returns the installed plugin record.
    case pluginsInstall(source: String, version: String?)
    /// Uninstall the plugin whose plugins.yml entry matches `source` ("github:owner/repo").
    /// Removes the bundle, updates plugins.yml + plugins-lock.yml + registry.
    case pluginsUninstall(source: String)
}

// MARK: - IPCResponse

/// Envelope sent from the app back to the CLI.
public struct IPCResponse: Codable, Sendable, Equatable {
    public let version: Int
    public let requestID: String
    public let result: IPCResult

    public init(version: Int = ipcProtocolVersion, requestID: String, result: IPCResult) {
        self.version = version
        self.requestID = requestID
        self.result = result
    }
}

// MARK: - IPCResult

/// Result payload — either success with data or a typed error.
public enum IPCResult: Codable, Sendable, Equatable {
    case success(IPCPayload)
    case failure(IPCError)
}

// MARK: - IPCPayload

/// Success payloads for each command type.
public enum IPCPayload: Codable, Sendable, Equatable {
    /// Response to `.list`.
    case widgetList([WidgetInfoDTO])
    /// Response to `.getWidget`.
    case widgetDetail(WidgetInfoDTO)
    /// Response to `.setWidget`, `.setGlobal`, `.reload`.
    case ok
    /// Acknowledgement for `.subscribe` — lists the events the server accepted.
    case subscribeAck(events: [String])
    /// Response to `.showToast` — the assigned toast ID.
    case toastID(String)
    /// Response to `.pluginsList`.
    case pluginList([PluginManifestEntryDTO])
    /// Response to `.pluginsInstall`.
    case pluginInstalled(InstalledPluginDTO)
}

// MARK: - IPCError

/// Typed errors transmitted over the wire.
public enum IPCError: Codable, Sendable, Equatable, Error {
    case unknownCommand
    case widgetNotFound(id: String)
    case invalidKeyPath(String)
    case invalidValue(key: String, reason: String)
    case versionMismatch(serverVersion: Int, clientVersion: Int)
    case internalError(String)
}

// MARK: - PluginManifestEntryDTO

/// One entry from plugins.yml combined with its resolved lock state.
public struct PluginManifestEntryDTO: Codable, Sendable, Equatable {
    /// "github:owner/repo" format.
    public let source: String
    /// Version declared in plugins.yml ("1.2.0" or "latest").
    public let declaredVersion: String
    /// resolvedVersion from plugins-lock.yml; nil if unresolved.
    public let resolvedVersion: String?
    /// zipSHA256 from plugins-lock.yml; nil if unresolved.
    public let zipSHA256: String?
    /// Matching DylibPluginManifest.id; nil if unresolved.
    public let pluginID: String?

    public init(
        source: String,
        declaredVersion: String,
        resolvedVersion: String?,
        zipSHA256: String?,
        pluginID: String?,
    ) {
        self.source = source
        self.declaredVersion = declaredVersion
        self.resolvedVersion = resolvedVersion
        self.zipSHA256 = zipSHA256
        self.pluginID = pluginID
    }
}

// MARK: - InstalledPluginDTO

/// One installed plugin record returned by `.pluginsInstall`.
public struct InstalledPluginDTO: Codable, Sendable, Equatable {
    /// DylibPluginManifest.id (reverse-DNS).
    public let id: String
    /// Display name from the plugin manifest.
    public let name: String
    /// Installed version (normalized, no leading "v").
    public let version: String
    /// On-disk bundle name (e.g. "MyWidget.statusplugin").
    public let bundleName: String
    /// "github:owner/repo" — the plugins.yml source string.
    public let source: String
    /// Wall-clock install time.
    public let installedAt: Date

    public init(
        id: String,
        name: String,
        version: String,
        bundleName: String,
        source: String,
        installedAt: Date,
    ) {
        self.id = id
        self.name = name
        self.version = version
        self.bundleName = bundleName
        self.source = source
        self.installedAt = installedAt
    }
}
