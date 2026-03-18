@testable import StatusBarKit
import Testing

struct SemanticVersionTests {
    @Test
    func `Parses major.minor.patch`() {
        let v = SemanticVersion("1.2.3")
        #expect(v != nil)
        #expect(v?.major == 1)
        #expect(v?.minor == 2)
        #expect(v?.patch == 3)
    }

    @Test
    func `Parses major.minor (patch defaults to 0)`() {
        let v = SemanticVersion("2.5")
        #expect(v != nil)
        #expect(v?.major == 2)
        #expect(v?.minor == 5)
        #expect(v?.patch == 0)
    }

    @Test
    func `Returns nil for invalid input`() {
        #expect(SemanticVersion("abc") == nil)
        #expect(SemanticVersion("1") == nil)
        #expect(SemanticVersion("") == nil)
    }

    @Test
    func `Init with components`() {
        let v = SemanticVersion(major: 3, minor: 1, patch: 4)
        #expect(v.major == 3)
        #expect(v.minor == 1)
        #expect(v.patch == 4)
    }

    // MARK: - Comparable

    @Test
    func `Less than comparison`() {
        let v1 = SemanticVersion(major: 1, minor: 0, patch: 0)
        let v2 = SemanticVersion(major: 2, minor: 0, patch: 0)
        #expect(v1 < v2)
        #expect(!(v2 < v1))
    }

    @Test
    func `Minor version ordering`() {
        let v1 = SemanticVersion(major: 1, minor: 2, patch: 0)
        let v2 = SemanticVersion(major: 1, minor: 3, patch: 0)
        #expect(v1 < v2)
    }

    @Test
    func `Patch version ordering`() {
        let v1 = SemanticVersion(major: 1, minor: 2, patch: 3)
        let v2 = SemanticVersion(major: 1, minor: 2, patch: 4)
        #expect(v1 < v2)
    }

    @Test
    func `Equal versions are not less than`() {
        let v = SemanticVersion(major: 1, minor: 2, patch: 3)
        #expect(!(v < v))
    }

    // MARK: - Compatibility

    @Test
    func `Compatible when same major, plugin minor <= host minor`() {
        let host = SemanticVersion(major: 1, minor: 3, patch: 0)
        let plugin = SemanticVersion(major: 1, minor: 2, patch: 5)
        #expect(host.isCompatible(with: plugin))
    }

    @Test
    func `Compatible when same major and same minor`() {
        let host = SemanticVersion(major: 1, minor: 3, patch: 0)
        let plugin = SemanticVersion(major: 1, minor: 3, patch: 9)
        #expect(host.isCompatible(with: plugin))
    }

    @Test
    func `Incompatible when plugin minor > host minor`() {
        let host = SemanticVersion(major: 1, minor: 2, patch: 0)
        let plugin = SemanticVersion(major: 1, minor: 3, patch: 0)
        #expect(!host.isCompatible(with: plugin))
    }

    @Test
    func `Incompatible when major versions differ`() {
        let host = SemanticVersion(major: 2, minor: 0, patch: 0)
        let plugin = SemanticVersion(major: 1, minor: 0, patch: 0)
        #expect(!host.isCompatible(with: plugin))
    }
}
