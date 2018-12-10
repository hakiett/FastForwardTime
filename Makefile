export TARGET = iphone:9.2:9.2

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = FastForwardTime
FastForwardTime_FILES = Tweak.xm
FastForwardTime_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += fftpref
include $(THEOS_MAKE_PATH)/aggregate.mk
