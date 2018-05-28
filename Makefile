ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CCXSupport
CCXSupport_FILES = Tweak.x CCUIVPNSettings.m CCUISSHSettings.m
CCXSupport_PRIVATE_FRAMEWORKS = ControlCenterUI
CCXSupport_CFLAGS = -fobjc-arc

TOOL_NAME = toggledropbear
toggledropbear_FILES = toggledropbear.m
toggledropbear_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/tool.mk

after-install::
	install.exec "killall -9 SpringBoard"
