TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = GeometryJump

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = dindeinject

dindeinject_FILES = src/main.m src/utils/utils.m src/utils/dyld_bypass_validation.m src/geode.m src/utils/FixCydiaSubstrate.c fishhook/*.c
dindeinject_CFLAGS = -fobjc-arc
dindeinject_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries

include $(THEOS_MAKE_PATH)/library.mk
