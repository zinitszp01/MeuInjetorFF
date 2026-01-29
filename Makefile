ARCHS = arm64
TARGET = iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SensiInjetor
SensiInjetor_FILES = Tweak.xm
SensiInjetor_FRAMEWORKS = UIKit QuartzCore CoreGraphics
# A linha abaixo ignora o erro de 'keyWindow' e permite a build
SensiInjetor_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable

include $(THEOS_MAKE_PATH)/tweak.mk
