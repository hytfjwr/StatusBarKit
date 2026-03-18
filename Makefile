.PHONY: build test clean lint format format-check package

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

package:
	swift build -c release
	rm -rf .build/package StatusBarKit.zip
	mkdir -p .build/package/lib .build/package/Modules
	cp .build/release/libStatusBarKit.dylib .build/package/lib/
	cp -r .build/release/Modules/StatusBarKit.swiftmodule .build/package/Modules/
	cd .build/package && zip -r ../../StatusBarKit.zip lib Modules
