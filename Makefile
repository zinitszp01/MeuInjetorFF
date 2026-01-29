ARCHS = arm64
TARGET := iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SensiInjetor
SensiInjetor_FILES = Tweak.x
SensiInjetor_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
