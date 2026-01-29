ARCHS = arm64
TARGET := iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SensiInjetor
SensiInjetor_FILES = Tweak.x
SensiInjetor_CFLAGS = -fobjc-arc -w -Wno-error
SensiInjetor_FRAMEWORKS = UIKit CoreGraphics QuartzCore
# Importante para o Bypass e Hooks de Memória
SensiInjetor_LDFLAGS = -lsubstitute

include $(THEOS_MAKE_PATH)/tweak.mk
