ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CCXSupport
CCXSupport_FILES = Tweak.x CCUIFSCompatibilityLayer.m
CCXSupport_PRIVATE_FRAMEWORKS = ControlCenterUI
CCXSupport_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
