@testable import StatusBarKit
import Testing

struct ShellCommandTests {
    @Test
    func `Shell API executes command and returns output`() async throws {
        let output = try await ShellCommand.run("echo hello")
        #expect(output == "hello")
    }

    @Test
    func `Argv API executes command and returns output`() async throws {
        let output = try await ShellCommand.run("echo", arguments: ["world"])
        #expect(output == "world")
    }

    @Test
    func `Output is trimmed of surrounding whitespace`() async throws {
        let output = try await ShellCommand.run("printf", arguments: ["  spaced  "])
        #expect(output == "spaced")
    }

    @Test
    func `Timeout throws ShellCommandError.timeout`() async throws {
        await #expect(throws: ShellCommandError.timeout) {
            try await ShellCommand.run("sleep 1", timeout: 0.1)
        }
    }

    @Test
    func `Argv API correctly passes multiple arguments`() async throws {
        let output = try await ShellCommand.run("printf", arguments: ["%s-%s", "hello", "world"])
        #expect(output == "hello-world")
    }
}
