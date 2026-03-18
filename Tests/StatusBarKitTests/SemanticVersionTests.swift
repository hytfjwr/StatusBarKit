import Testing
@testable import StatusBarKit

@Suite("SemanticVersion")
struct SemanticVersionTests {
    @Test("Parses major.minor.patch")
    func parsesThreeComponents() {
        let v = SemanticVersion("1.2.3")
        #expect(v != nil)
        #expect(v?.major == 1)
        #expect(v?.minor == 2)
        #expect(v?.patch == 3)
    }

    @Test("Parses major.minor (patch defaults to 0)")
    func parsesTwoComponents() {
        let v = SemanticVersion("2.5")
        #expect(v != nil)
        #expect(v?.major == 2)
        #expect(v?.minor == 5)
        #expect(v?.patch == 0)
    }

    @Test("Returns nil for invalid input")
    func invalidInput() {
        #expect(SemanticVersion("abc") == nil)
        #expect(SemanticVersion("1") == nil)
        #expect(SemanticVersion("") == nil)
    }

    @Test("Init with components")
    func initWithComponents() {
        let v = SemanticVersion(major: 3, minor: 1, patch: 4)
        #expect(v.major == 3)
        #expect(v.minor == 1)
        #expect(v.patch == 4)
    }

    // MARK: - Comparable

    @Test("Less than comparison")
    func lessThan() {
        let v1 = SemanticVersion(major: 1, minor: 0, patch: 0)
        let v2 = SemanticVersion(major: 2, minor: 0, patch: 0)
        #expect(v1 < v2)
        #expect(!(v2 < v1))
    }

    @Test("Minor version ordering")
    func minorOrdering() {
        let v1 = SemanticVersion(major: 1, minor: 2, patch: 0)
        let v2 = SemanticVersion(major: 1, minor: 3, patch: 0)
        #expect(v1 < v2)
    }

    @Test("Patch version ordering")
    func patchOrdering() {
        let v1 = SemanticVersion(major: 1, minor: 2, patch: 3)
        let v2 = SemanticVersion(major: 1, minor: 2, patch: 4)
        #expect(v1 < v2)
    }

    @Test("Equal versions are not less than")
    func equalNotLessThan() {
        let v = SemanticVersion(major: 1, minor: 2, patch: 3)
        #expect(!(v < v))
    }

    // MARK: - Compatibility

    @Test("Compatible when same major, plugin minor <= host minor")
    func compatibleSameMajor() {
        let host = SemanticVersion(major: 1, minor: 3, patch: 0)
        let plugin = SemanticVersion(major: 1, minor: 2, patch: 5)
        #expect(host.isCompatible(with: plugin))
    }

    @Test("Compatible when same major and same minor")
    func compatibleSameMinor() {
        let host = SemanticVersion(major: 1, minor: 3, patch: 0)
        let plugin = SemanticVersion(major: 1, minor: 3, patch: 9)
        #expect(host.isCompatible(with: plugin))
    }

    @Test("Incompatible when plugin minor > host minor")
    func incompatibleNewerMinor() {
        let host = SemanticVersion(major: 1, minor: 2, patch: 0)
        let plugin = SemanticVersion(major: 1, minor: 3, patch: 0)
        #expect(!host.isCompatible(with: plugin))
    }

    @Test("Incompatible when major versions differ")
    func incompatibleDifferentMajor() {
        let host = SemanticVersion(major: 2, minor: 0, patch: 0)
        let plugin = SemanticVersion(major: 1, minor: 0, patch: 0)
        #expect(!host.isCompatible(with: plugin))
    }
}
