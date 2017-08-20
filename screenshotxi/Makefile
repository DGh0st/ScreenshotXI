export TARGET = iphone:clang:8.1:latest

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = ScreenshotXI
ScreenshotXI_FILES = $(wildcard *.xm)
ScreenshotXI_INSTALL_PATH = /Library/PreferenceBundles
ScreenshotXI_FRAMEWORKS = UIKit MessageUI
ScreenshotXI_PRIVATE_FRAMEWORKS = Preferences
ScreenshotXI_LIBRARIES = colorpicker

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/ScreenshotXI.plist$(ECHO_END)
