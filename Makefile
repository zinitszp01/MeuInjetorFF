ARCHS = arm64
TARGET := iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SensiInjetor
# Adicionamos o caminho do bypass nos arquivos de compilação
SensiInjetor_FILES = Tweak.x Bypass/Anticheat.mm
SensiInjetor_CFLAGS = -fobjc-arc -I./Bypass -w
SensiInjetor_FRAMEWORKS = UIKit CoreGraphics QuartzCore
SensiInjetor_LDFLAGS = -lsubstitute

include $(THEOS_MAKE_PATH)/tweak.mk
