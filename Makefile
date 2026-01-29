ARCHS = arm64
TARGET := iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SensiInjetor
SensiInjetor_FILES = Tweak.x
# Força o compilador a ignorar todos os avisos e erros de depreciação
SensiInjetor_CFLAGS = -fobjc-arc -w -Wno-error -Wno-deprecated-declarations

SensiInjetor_FRAMEWORKS = UIKit Foundation

include $(THEOS_MAKE_PATH)/tweak.mk
