.PHONY: build test clean lint format format-check

build:
	swift build

test:
	swift test

clean:
	swift package clean

lint:
	swiftlint lint --strict

format:
	swiftformat .

format-check:
	swiftformat --lint .
