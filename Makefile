ARCHS = arm64
TARGET := iphone:clang:latest:14.0

export codesign_identity = 

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SensiInjetor
SensiInjetor_FILES = Tweak.x
SensiInjetor_CFLAGS = -fobjc-arc -w -Wno-error
SensiInjetor_FRAMEWORKS = UIKit CoreGraphics QuartzCore

include $(THEOS_MAKE_PATH)/tweak.mk
