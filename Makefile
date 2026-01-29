# Arquitetura para iPhones modernos (6s até o 14/15)
ARCHS = arm64

# Define o alvo como iPhone e a versão mínima do iOS
TARGET := iphone:clang:latest:14.0

# Inclui as configurações padrão do Theos
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SensiInjetor

# Arquivos que serão compilados
SensiInjetor_FILES = Tweak.x

# Flags para o compilador (ARC ajuda na memória)
SensiInjetor_CFLAGS = -fobjc-arc

# Frameworks necessários para o alerta aparecer na tela
SensiInjetor_FRAMEWORKS = UIKit Foundation

include $(THEOS_MAKE_PATH)/tweak.mk
