ARCHS = arm64
TARGET := iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SensiInjetor
# O segredo está em compilar os dois arquivos juntos
SensiInjetor_FILES = Tweak.x Bypass/Anticheat.mm
SensiInjetor_CFLAGS = -fobjc-arc -I./Bypass -w
SensiInjetor_FRAMEWORKS = UIKit CoreGraphics QuartzCore

include $(THEOS_MAKE_PATH)/tweak.mk
