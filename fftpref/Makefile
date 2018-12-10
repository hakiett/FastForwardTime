export TARGET = iphone:9.2:9.2

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = FFTPref
FFTPref_FILES = FFTRootListController.m
FFTPref_INSTALL_PATH = /Library/PreferenceBundles
FFTPref_FRAMEWORKS = UIKit
FFTPref_PRIVATE_FRAMEWORKS = Preferences
FFTPref_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/FastForwardTime.plist$(ECHO_END)
