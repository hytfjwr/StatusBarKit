import Testing
@testable import StatusBarKit

@Suite("ShellCommand")
struct ShellCommandTests {
    @Test("Shell API executes command and returns output")
    func shellAPIBasic() async throws {
        let output = try await ShellCommand.run("echo hello")
        #expect(output == "hello")
    }

    @Test("Argv API executes command and returns output")
    func argvAPIBasic() async throws {
        let output = try await ShellCommand.run("echo", arguments: ["world"])
        #expect(output == "world")
    }

    @Test("Output is trimmed of surrounding whitespace")
    func outputTrimmed() async throws {
        let output = try await ShellCommand.run("printf", arguments: ["  spaced  "])
        #expect(output == "spaced")
    }

    @Test("Timeout throws ShellCommandError.timeout")
    func timeoutThrows() async throws {
        await #expect(throws: ShellCommandError.timeout) {
            try await ShellCommand.run("sleep 1", timeout: 0.1)
        }
    }

    @Test("Argv API correctly passes multiple arguments")
    func argvMultipleArguments() async throws {
        let output = try await ShellCommand.run("printf", arguments: ["%s-%s", "hello", "world"])
        #expect(output == "hello-world")
    }
}
