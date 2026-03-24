import Foundation

// MARK: - ShellCommandError

/// Errors thrown by ``ShellCommand``.
public enum ShellCommandError: LocalizedError, Equatable {
    /// The process did not finish within the specified timeout interval.
    case timeout

    /// The process exited with a non-zero status.
    case nonZeroExit(ShellCommandResult)

    public var errorDescription: String? {
        switch self {
        case .timeout: "Shell command timed out"
        case let .nonZeroExit(result): "Command exited with code \(result.exitCode): \(result.stderr)"
        }
    }
}

// MARK: - ShellCommandResult

/// The complete result of a shell command execution.
public struct ShellCommandResult: Sendable, Equatable {
    /// Standard output (trimmed).
    public let stdout: String
    /// Standard error (trimmed).
    public let stderr: String
    /// Process exit code.
    public let exitCode: Int32
}

// MARK: - ShellCommand

public enum ShellCommand {
    private static let defaultEnvironment: [String: String] = ProcessInfo.processInfo.environment.merging([
        "PATH": "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin",
    ]) { _, new in new }

    /// Executes an external command using an argv array (no shell interpretation).
    /// This is the preferred API — immune to shell injection.
    /// Throws ``ShellCommandError/nonZeroExit(_:)`` when the process exits with a non-zero status.
    public static func run(_ executable: String, arguments: [String], timeout: TimeInterval = 5) async throws -> String {
        let result = try await runWithResult(executable, arguments: arguments, timeout: timeout)
        guard result.exitCode == 0 else {
            throw ShellCommandError.nonZeroExit(result)
        }
        return result.stdout
    }

    /// Executes a shell command via `/bin/bash -c`. Use the argv-based overload instead
    /// when any part of the command includes external/user-controlled data.
    /// Throws ``ShellCommandError/nonZeroExit(_:)`` when the process exits with a non-zero status.
    public static func run(_ command: String, timeout: TimeInterval = 5) async throws -> String {
        let result = try await runWithResult(command, timeout: timeout)
        guard result.exitCode == 0 else {
            throw ShellCommandError.nonZeroExit(result)
        }
        return result.stdout
    }

    /// Executes an external command and returns the full result including stderr and exit code.
    /// Does not throw on non-zero exit — the caller decides how to handle exit codes.
    public static func runWithResult(
        _ executable: String, arguments: [String], timeout: TimeInterval = 5,
    ) async throws -> ShellCommandResult {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = [executable] + arguments
        return try await runProcess(process, timeout: timeout)
    }

    /// Executes a shell command via `/bin/bash -c` and returns the full result.
    /// Does not throw on non-zero exit — the caller decides how to handle exit codes.
    public static func runWithResult(
        _ command: String, timeout: TimeInterval = 5,
    ) async throws -> ShellCommandResult {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = ["-c", command]
        return try await runProcess(process, timeout: timeout)
    }

    private static func runProcess(_ process: Process, timeout: TimeInterval) async throws -> ShellCommandResult {
        try await withCheckedThrowingContinuation { continuation in
            let stdoutPipe = Pipe()
            let stderrPipe = Pipe()
            process.standardOutput = stdoutPipe
            process.standardError = stderrPipe
            process.environment = defaultEnvironment

            nonisolated(unsafe) var didTimeout = false
            nonisolated(unsafe) let workItem = DispatchWorkItem {
                if process.isRunning {
                    didTimeout = true
                    process.terminate()
                }
            }
            DispatchQueue.global().asyncAfter(deadline: .now() + timeout, execute: workItem)

            process.terminationHandler = { proc in
                workItem.cancel()
                if didTimeout {
                    continuation.resume(throwing: ShellCommandError.timeout)
                    return
                }
                let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
                let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
                let stdout = String(data: stdoutData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                let stderr = String(data: stderrData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                let result = ShellCommandResult(stdout: stdout, stderr: stderr, exitCode: proc.terminationStatus)
                continuation.resume(returning: result)
            }

            do {
                try process.run()
            } catch {
                workItem.cancel()
                process.terminationHandler = nil
                continuation.resume(throwing: error)
            }
        }
    }
}
