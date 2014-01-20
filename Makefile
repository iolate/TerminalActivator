FW_DEVICE_IP=10.0.1.3

include theos/makefiles/common.mk

TWEAK_NAME = TerminalActivator
TerminalActivator_FILES = Tweak.xm
TerminalActivator_LDFLAGS = -lactivator

BUNDLE_NAME = TerminalActivatorSettings
TerminalActivatorSettings_FILES = TerminalActivatorSettings.mm
TerminalActivatorSettings_INSTALL_PATH = /Library/PreferenceBundles
TerminalActivatorSettings_FRAMEWORKS = UIKit
TerminalActivatorSettings_PRIVATE_FRAMEWORKS = Preferences
TerminalActivatorSettings_LDFLAGS = -lactivator

TOOL_NAME = notify_post
notify_post_FILES = main.mm

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/tool.mk
include $(THEOS_MAKE_PATH)/bundle.mk
