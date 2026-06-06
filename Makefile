.PHONY: build build-release run clean open

BUILD_DIR = .build
APP_NAME = Uninstaller
APP_BUNDLE = build/$(APP_NAME).app

build:
	swift build

build-release:
	swift build -c release

run: build
	swift run

# Build a proper .app bundle
app: build-release
	rm -rf $(APP_BUNDLE)
	mkdir -p $(APP_BUNDLE)/Contents/MacOS
	mkdir -p $(APP_BUNDLE)/Contents/Resources
	cp $(BUILD_DIR)/release/$(APP_NAME) $(APP_BUNDLE)/Contents/MacOS/
	cp Info.plist $(APP_BUNDLE)/Contents/
	touch $(APP_BUNDLE)
	
	# Generate a simple icon if needed
	@if [ ! -f AppIcon.icns ]; then \
		echo "No AppIcon.icns found, using default"; \
	fi
	
	@echo "✅ App bundle created at: $(APP_BUNDLE)"
	@echo "Run: open $(APP_BUNDLE)"

open:
	open Package.swift

clean:
	rm -rf $(BUILD_DIR)
	rm -rf build

# Build with Xcode (requires Xcode installed)
xcode:
	xcodebuild -scheme Uninstaller -derivedDataPath build/Xcode build

# Run the built app bundle
run-app: app
	open $(APP_BUNDLE)
