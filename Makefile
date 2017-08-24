export ARCHS = armv7 arm64
export TARGET = iphone:clang:latest:latest

PACKAGE_VERSION = $(THEOS_PACKAGE_BASE_VERSION)-1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ScreenshotXI
ScreenshotXI_FILES = $(wildcard *.xm)
ScreenshotXI_FRAMEWORKS = UIKit CoreGraphics QuartzCore Photos
ScreenshotXI_PRIVATE_FRAMEWORKS = PhotoLibrary MarkupUI AudioToolbox
ScreenshotXI_LIBRARIES = colorpicker

include $(THEOS_MAKE_PATH)/tweak.mk

BUNDLE_NAME = ImageAssets
ImageAssets_INSTALL_PATH = /Library/Application Support/ScreenshotXI

include $(THEOS_MAKE_PATH)/bundle.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += screenshotxi
include $(THEOS_MAKE_PATH)/aggregate.mk
