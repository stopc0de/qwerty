.PHONY: build build-release run clean open icon

BUILD_DIR = .build
APP_NAME = Uninstaller
APP_BUNDLE = build/$(APP_NAME).app
ICON_SRC = AppIcon.png
# Changed to "icons.icns" so it matches the "icons" namespace
ICON_DST = $(APP_BUNDLE)/Contents/Resources/icons.icns
PLIST_SRC = Info.plist

build:
	swift build

build-release:
	swift build -c release

run: build
	swift run

# Generate icon from gen_icon.swift
icon:
	swift gen_icon.swift
	@echo "Icon generated: $(ICON_SRC)"

# Build a proper .app bundle
app: build-release icon
	rm -rf $(APP_BUNDLE)
	mkdir -p $(APP_BUNDLE)/Contents/MacOS
	mkdir -p $(APP_BUNDLE)/Contents/Resources
	cp $(BUILD_DIR)/release/$(APP_NAME) $(APP_BUNDLE)/Contents/MacOS/
	cp $(PLIST_SRC) $(APP_BUNDLE)/Contents/
	# Convert PNG to ICNS using iconutil
	mkdir -p AppIcon.iconset
	sips -z 16 16 $(ICON_SRC) --out AppIcon.iconset/icon_16x16.png 2>/dev/null
	sips -z 32 32 $(ICON_SRC) --out AppIcon.iconset/icon_16x16@2x.png 2>/dev/null
	sips -z 32 32 $(ICON_SRC) --out AppIcon.iconset/icon_32x32.png 2>/dev/null
	sips -z 64 64 $(ICON_SRC) --out AppIcon.iconset/icon_32x32@2x.png 2>/dev/null
	sips -z 128 128 $(ICON_SRC) --out AppIcon.iconset/icon_128x128.png 2>/dev/null
	sips -z 256 256 $(ICON_SRC) --out AppIcon.iconset/icon_128x128@2x.png 2>/dev/null
	sips -z 256 256 $(ICON_SRC) --out AppIcon.iconset/icon_256x256.png 2>/dev/null
	sips -z 512 512 $(ICON_SRC) --out AppIcon.iconset/icon_256x256@2x.png 2>/dev/null
	sips -z 512 512 $(ICON_SRC) --out AppIcon.iconset/icon_512x512.png 2>/dev/null
	sips -z 1024 1024 $(ICON_SRC) --out AppIcon.iconset/icon_512x512@2x.png 2>/dev/null
	iconutil -c icns AppIcon.iconset
	rm -rf AppIcon.iconset
	# Rename to icons.icns (matches our constant name)
	mv AppIcon.icns $(ICON_DST)
	# Update Info.plist inside the bundle to reference "icons" as the icon file
	/usr/libexec/PlistBuddy -c "Set :CFBundleIconFile icons" $(APP_BUNDLE)/Contents/Info.plist 2>/dev/null || \
	/usr/libexec/PlistBuddy -c "Add :CFBundleIconFile string icons" $(APP_BUNDLE)/Contents/Info.plist
	@echo "file create(^w^)"
	@echo "✅ App bundle created at: $(APP_BUNDLE)"
	@echo "Run: open $(APP_BUNDLE)"

open:
	open Package.swift

clean:
	rm -rf $(BUILD_DIR)
	rm -rf build
	rm -f AppIcon.png AppIcon.icns icons.icns

# Build with Xcode (requires Xcode installed)
xcode:
	xcodebuild -scheme Uninstaller -derivedDataPath build/Xcode build

# Run the built app bundle
run-app: app
	open $(APP_BUNDLE)

#wow
