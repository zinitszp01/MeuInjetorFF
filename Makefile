ARCHS = arm64
TARGET := iphone:clang:latest:14.0

# Esta linha abaixo resolve o erro 'ldid: command not found'
export codesign_identity = 

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SensiInjetor
SensiInjetor_FILES = Tweak.x
SensiInjetor_CFLAGS = -fobjc-arc -w -Wno-error -Wno-deprecated-declarations

SensiInjetor_FRAMEWORKS = UIKit Foundation

include $(THEOS_MAKE_PATH)/tweak.mk
