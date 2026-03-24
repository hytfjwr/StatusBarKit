# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [1.4.1] - 2026-03-24

- fix: preserve ABI compatibility for types moved to StatusBarIPC (#19)

## [1.4.0] - 2026-03-24

- feat: add StatusBarIPC target for CLI communication (#16)

## [1.3.0] - 2026-03-24

- feat: add ShellCommandResult and runWithResult API (#14)

## [1.2.0] - 2026-03-24

- fix: apply tint overlay to popup panels (#12)
- docs: update README to reflect actual plugin development flow
- fix(ci): skip version-check for release branches (#11)

## [1.1.1] - 2026-03-20

- ci: add version check and split release workflow into two phases (#9)

## [1.1.0] - 2026-03-20

- fix(ci): scope CHANGELOG and release notes to changes since last tag
- feat: add preferredSettingsSize to StatusBarWidget protocol (#7)
- chore: remove unused placeholder files (#6)
- build(deps): bump actions/checkout from 4 to 6 (#4)
- ci: add reviewer to Dependabot configuration (#5)
- ci: add Dependabot configuration (#3)
